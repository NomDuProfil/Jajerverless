data "aws_caller_identity" "aws_information" {}

locals {
  endpoint_configuration = flatten([
    for endpoint_key, endpoint in var.endpoints_name : [
      for permission_key, permission in endpoint.permissions_databases : {
        endpoint_key = endpoint_key
        permission_key  = permission_key
        database = permission.databases
        permission = permission.permissions
      }
    ]
  ])
}

data "aws_iam_policy_document" "policy_document_database" {
  for_each = {
    for endpoint in local.endpoint_configuration : "${endpoint.endpoint_key}.${endpoint.permission_key}" => endpoint
  }

  statement {
    actions = formatlist("dynamodb:%s", each.value.permission)
    resources = formatlist("arn:aws:dynamodb:${var.lambda_region}:${data.aws_caller_identity.aws_information.account_id}:table/%s", each.value.database)
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  for_each = {
    for endpoint in local.endpoint_configuration : "${endpoint.endpoint_key}.${endpoint.permission_key}" => endpoint
  }

  name = "lambda_policy_${each.value.endpoint_key}"
  role = aws_iam_role.iam_for_lambda[each.key].id

  policy = data.aws_iam_policy_document.policy_document_database[each.key].json
}

resource "aws_iam_role" "iam_for_lambda" {
  for_each = {
    for endpoint in local.endpoint_configuration : "${endpoint.endpoint_key}.${endpoint.permission_key}" => endpoint
  }

  name = "iam_for_lambda_${each.value.endpoint_key}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "lambda_zip_dir" {
    for_each = {
      for endpoint in local.endpoint_configuration : "${endpoint.endpoint_key}.${endpoint.permission_key}" => endpoint
    }

    type        = "zip"
    output_path = "/tmp/${each.value.endpoint_key}.zip"
    source_dir  = "${var.path_base}${each.value.endpoint_key}"
}

resource "aws_lambda_function" "lambda_zip_dir" {
    for_each = {
      for endpoint in local.endpoint_configuration : "${endpoint.endpoint_key}.${endpoint.permission_key}" => endpoint
    }

    filename            = data.archive_file.lambda_zip_dir[each.key].output_path
    source_code_hash    = data.archive_file.lambda_zip_dir[each.key].output_base64sha256
    function_name       = each.value.endpoint_key
    handler             = "${each.value.endpoint_key}.lambda_handler"
    role                = aws_iam_role.iam_for_lambda[each.key].arn
    runtime             = "python3.9"
}

data "template_file" api_swagger {
    template = "${file("${var.path_base}/swagger.yaml")}"

    vars = {
        uri_start   = "arn:aws:apigateway:${var.lambda_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.lambda_region}:${data.aws_caller_identity.aws_information.account_id}:function:",
        uri_end     = "/invocations"
    }
}

resource "aws_api_gateway_rest_api" "api_gw" {
    name    = var.name_api
    body    = data.template_file.api_swagger.rendered
    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

resource "aws_lambda_permission" "lambda_permission" {
    for_each = {
      for endpoint in local.endpoint_configuration : "${endpoint.endpoint_key}.${endpoint.permission_key}" => endpoint
    }

    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_zip_dir[each.key].function_name
    principal     = "apigateway.amazonaws.com"

    source_arn = "${aws_api_gateway_rest_api.api_gw.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_gw_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api_gw.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "production" {
  deployment_id = aws_api_gateway_deployment.api_gw_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gw.id
  stage_name    = "production"
}

resource "aws_api_gateway_api_key" "default_api_key" {
  name = "${var.name_api}_default_api_key"
}

resource "aws_api_gateway_usage_plan" "api_gw_usage_plan" {
  name         = "jaj-usage-plan"
  description  = "Usage plan JAJ"
  product_code = "MYCODE"

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gw.id
    stage  = aws_api_gateway_stage.production.stage_name
  }

  quota_settings {
    limit  = 10000
    offset = 2
    period = "WEEK"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

resource "aws_api_gateway_usage_plan_key" "api_gw_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.default_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_gw_usage_plan.id
}

resource "aws_api_gateway_base_path_mapping" "api_gw_mapping" {
  api_id      = aws_api_gateway_rest_api.api_gw.id
  stage_name  = aws_api_gateway_stage.production.stage_name
  domain_name = var.domain_name_api
}