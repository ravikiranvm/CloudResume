# Create a Hosted Zone
resource "aws_route53_zone" "main" {
    name = "raviki.online"
}

# Region for ACM certificate
provider "aws" {
    alias = "us-east-1"
    region = "us-east-1"
}


# Request SSL Certificate
resource "aws_acm_certificate" "ssl_cert" {
    provider = aws.us-east-1
    domain_name = "raviki.online"
    validation_method = "DNS"

    subject_alternative_names = [
        "www.raviki.online"
    ]
}

# DNS Validation
resource "aws_route53_record" "validation_record" {
    for_each = {
      for dvo in aws_acm_certificate.ssl_cert.domain_validation_options : dvo.domain_name => {
        name = dvo.resource_record_name
        type = dvo.resource_record_type
        value = dvo.resource_record_value
      }
    }

    zone_id = aws_route53_zone.main.zone_id
    name = each.value.name
    type = each.value.type
    ttl = 300
    records = [each.value.value]
}

resource "aws_acm_certificate_validation" "ssl_validation" {
    provider = aws.us-east-1
    depends_on = [ aws_acm_certificate.ssl_cert, aws_route53_record.validation_record ]
    certificate_arn = aws_acm_certificate.ssl_cert.arn
    validation_record_fqdns = [for record in aws_route53_record.validation_record : record.fqdn]
  
}

resource "aws_route53_record" "cf-a-record" {
    zone_id = aws_route53_zone.main.zone_id
    name = "www.raviki.online"
    type = "A"

    alias {
        name = aws_cloudfront_distribution.s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
        evaluate_target_health = true
    }

    depends_on = [aws_acm_certificate.ssl_cert, aws_cloudfront_distribution.s3_distribution]
  
}

resource "aws_route53_record" "cf-aa-record" {
    zone_id = aws_route53_zone.main.zone_id
    name = "raviki.online"
    type = "A"

    alias {
        name = aws_cloudfront_distribution.s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
        evaluate_target_health = true
    }

    depends_on = [aws_acm_certificate.ssl_cert, aws_cloudfront_distribution.s3_distribution]
  
}

resource "aws_route53_record" "domain_email" {
    zone_id = aws_route53_zone.main.zone_id
    name = "raviki.online"
    type = "MX"
    ttl = 300

    records = [ "10 mx1.titan.email", "20 mx2.titan.email"]

    depends_on = [aws_acm_certificate.ssl_cert, aws_cloudfront_distribution.s3_distribution]
  
}

resource "aws_route53_record" "email_txt_record" {
    zone_id = aws_route53_zone.main.zone_id
    name = "raviki.online"
    type = "TXT"
    ttl = 300

    records = [ "v=spf1 include:spf.titan.email ~all" ]

    depends_on = [aws_acm_certificate.ssl_cert, aws_cloudfront_distribution.s3_distribution]
  
}

resource "aws_route53_record" "email_dkim_record" {
    zone_id = aws_route53_zone.main.zone_id
    name = "titan1._domainkey"
    type = "TXT"
    ttl = 300

    records = [ "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCKxU9GoAXrlutDH+JdRAJIpMFPM+q+/FCufpqdhJCtXTb0Sx3k5Kwdr+tzSzhbye9gXrc1wiOOZlkP5BEn/8bGujuntapOCJQ6AiE+/6FJ1fcz9VROM6JRZUVdd1JhECWxfgCFug2rg9TCtPvGbAhaXZ/++v1+67gbq6jm5nBeBwIDAQAB" ]

    depends_on = [aws_acm_certificate.ssl_cert, aws_cloudfront_distribution.s3_distribution]
  
}



output "name_servers" {
    value = aws_route53_zone.main.name_servers
}