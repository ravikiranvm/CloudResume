# Create S3 bucket for the website
resource "aws_s3_bucket" "website_bucket" {
    bucket = "raviki.online" 
}

# enable the s3 bucket as a static website
resource "aws_s3_bucket_website_configuration" "resume_website" {
    bucket = aws_s3_bucket.website_bucket.id

    index_document {
       suffix = "index.html"
    }
}

# enable object versioning
resource "aws_s3_bucket_versioning" "version" {
    bucket = aws_s3_bucket.website_bucket.id
    versioning_configuration {
      status = "Enabled"
    }
}

# bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {
    bucket = aws_s3_bucket.website_bucket.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    "Service": "cloudfront.amazonaws.com"
                }
                Action = "s3:GetObject"
                Resource = "${aws_s3_bucket.website_bucket.arn}/*"
                Condition = {
                    StringEquals = {
                        "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
                    }
                }
            }
        ]
    })
}


# index page of the website
resource "aws_s3_object" "index-html" {
    bucket = aws_s3_bucket.website_bucket.id
    key = "index.html"
    source = "${path.root}/../frontend/index.html"
    content_type = "text/html"
}

# index page CSS
resource "aws_s3_object" "index-css" {
    bucket = aws_s3_bucket.website_bucket.id
    key = "styles.css"
    source = "${path.root}/../frontend/styles.css"
    content_type = "text/css"
}

