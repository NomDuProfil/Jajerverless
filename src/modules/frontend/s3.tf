resource "aws_s3_bucket" "root_bucket" {
  bucket = var.domain_name
}

resource "aws_s3_bucket_policy" "root_bucket" {
  bucket = aws_s3_bucket.root_bucket.bucket
  policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.root_bucket.arn}/*"
            }
        ]
  })
}

resource "aws_s3_bucket_website_configuration" "root_bucket" {
  bucket = var.domain_name

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}