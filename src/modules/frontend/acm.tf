provider "aws" {
    alias = "acm_provider_frontend"
    region = var.acm_provider_frontend_region
}

resource "aws_acm_certificate" "ssl_certificate_frontend" {
  provider = aws.acm_provider_frontend

  domain_name = var.domain_name
  validation_method = "DNS"

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "route53_record_frondend" {
    depends_on = [var.zone_id]

    for_each = {
        for dvo in aws_acm_certificate.ssl_certificate_frontend.domain_validation_options : dvo.domain_name => {
            name = dvo.resource_record_name
            record = dvo.resource_record_value
            type = dvo.resource_record_type
        }
    }
    allow_overwrite = true
    name = each.value.name
    records = [each.value.record]
    ttl = 60
    type = each.value.type
    zone_id = var.zone_id
}


resource "aws_acm_certificate_validation" "cert_validation_frontend" {
  provider = aws.acm_provider_frontend
  
  certificate_arn = aws_acm_certificate.ssl_certificate_frontend.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record_frondend : record.fqdn]
}