output "domain_zone" {
  value = aws_route53_zone.zone
}

output "domain_validation_options" {
  value = aws_acm_certificate.cert.domain_validation_options
}
