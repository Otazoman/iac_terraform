resource "aws_acm_certificate" "cert" {
  provider = aws.us-east-1   
  domain_name = var.root_domain
  validation_method = "DNS"

  subject_alternative_names = [
    var.root_domain,
    "*.${var.root_domain}"
  ]

  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

#output "domain_validation_options" {
#  value = "${aws_acm_certificate.cert.domain_validation_options}"
#}

resource "aws_route53_zone" "zone" {
  name         = var.root_domain
  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
    Name = var.root_domain
  }
}

#output "domain_zone" {
#  value = "${aws_route53_zone.zone}"
#}

resource "aws_route53_record" "validations" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "acm_validation" {
  provider = aws.us-east-1   
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validations : record.fqdn]
}