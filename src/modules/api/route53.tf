resource "aws_api_gateway_domain_name" "api_gw_domain" {
  domain_name              = var.domain_name_api
  regional_certificate_arn = aws_acm_certificate.ssl_certificate_api.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "api_domain" {
  depends_on = [var.zone_id]

  name    = aws_api_gateway_domain_name.api_gw_domain.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.api_gw_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gw_domain.regional_zone_id
  }
}