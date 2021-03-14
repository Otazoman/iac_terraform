resource "aws_cloudfront_distribution" "static-site-dst" {
  origin {
    domain_name = aws_s3_bucket.static-site.bucket_regional_domain_name
    origin_id   = local.s3-origin-id-static-site
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static-site-idntity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.root_domain
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront-logging.bucket_regional_domain_name
    prefix          = "cloudfront"
  }

  aliases = [
    var.root_domain,
    "www.${var.root_domain}"
  ]

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    minimum_protocol_version       = "TLSv1.2_2019"
    ssl_support_method             = "sni-only"
    cloudfront_default_certificate = false
  }

  custom_error_response {
    error_code         = "404"
    response_code      = "200"
    response_page_path = "/404.html"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3-origin-id-static-site
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  depends_on = [aws_acm_certificate.cert, aws_s3_bucket.static-site]
}

resource "aws_cloudfront_origin_access_identity" "static-site-idntity" {
  comment = "access-identity-static-site.s3.amazonaws.com"
}

resource "aws_route53_record" "root_domain" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name = var.root_domain
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.static-site-dst.domain_name}"
    zone_id = "${aws_cloudfront_distribution.static-site-dst.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_domain" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name = var.site_domain
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.static-site-dst.domain_name}"
    zone_id = "${aws_cloudfront_distribution.static-site-dst.hosted_zone_id}"
    evaluate_target_health = false
  }
}