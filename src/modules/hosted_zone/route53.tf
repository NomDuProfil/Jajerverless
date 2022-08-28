resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = var.common_tags
}

output "zone_id_output" {
  value = aws_route53_zone.main.zone_id
}