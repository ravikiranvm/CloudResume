# OAC for S3 bucket
resource "aws_cloudfront_origin_access_control" "oac" {
    name = "cf-oac"
    description = "OAC for accessing S3 bucket website"
    origin_access_control_origin_type = "s3"
    signing_behavior = "always"
    signing_protocol = "sigv4"
}

# Cloudfront distribution of resume website
resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
      domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
      origin_id = "website-origin"
    }

    enabled = true
    default_root_object = "index.html"

    default_cache_behavior {
      target_origin_id = "website-origin"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]

      forwarded_values {
        query_string = false
        cookies {
          forward = "none"
        }
      }

    }

    price_class = "PriceClass_All"

    viewer_certificate {
      cloudfront_default_certificate = true
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }



}

output "cf-domain" {
  description = "CF domain"
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}