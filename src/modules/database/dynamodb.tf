resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.database_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = var.primary_key
  range_key = var.range_key

  dynamic "attribute" {
    for_each = var.attributes

    content {
        name = attribute.value.name
        type = attribute.value.type
    }
  }

  #Bug de terraform ici : https://github.com/hashicorp/terraform-provider-aws/issues/10304
  #ttl {
  #  attribute_name = "TimeToExist"
  #  enabled        = false
  #}

  tags = var.common_tags
}