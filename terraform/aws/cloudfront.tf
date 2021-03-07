resource "aws_cloudfront_distribution" "static-site-dst" {
    origin {
        domain_name = aws_s3_bucket.static-site.bucket_regional_domain_name
        origin_id   = local.s3-origin-id-static-site
        s3_origin_config {
            origin_access_identity = aws_cloudfront_origin_access_identity.static-site-idntity.cloudfront_access_identity_path
        }
    }
    enabled             = true
    default_root_object = "index.html"
    wait_for_deployment = true

    # 独自ドメインを使用する場合はaliasを指定することでドメインでのアクセスも可能です
    # aliases             = ["xxxxxx.com"]

    # SSL証明書。ACMを使用する場合はここで指定すると利用可能です
    viewer_certificate {
        acm_certificate_arn            = ""
        cloudfront_default_certificate = true
        ssl_support_method             = ""
    }

    custom_error_response {
        error_code = "404"
        response_code = "200"
        response_page_path = "/404.html"
    }

    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = local.s3-origin-id-static-site
        compress         = true
        viewer_protocol_policy = "allow-all"
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
}

resource "aws_cloudfront_origin_access_identity" "static-site-idntity" {
    comment = "access-identity-static-site.s3.amazonaws.com"
}