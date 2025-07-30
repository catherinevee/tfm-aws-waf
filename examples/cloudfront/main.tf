# CloudFront WAF Example
# This example demonstrates WAF configuration with CloudFront distribution

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # CloudFront requires us-east-1 for certificates
}

# S3 bucket for CloudFront origin
resource "aws_s3_bucket" "website" {
  bucket = "my-waf-cloudfront-website-${random_string.bucket_suffix.result}"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy for CloudFront access
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.waf_cloudfront.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}

# ACM Certificate for CloudFront
resource "aws_acm_certificate" "cloudfront" {
  provider = aws.us-east-1
  domain_name       = "example.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 hosted zone (optional - for DNS validation)
resource "aws_route53_zone" "main" {
  name = "example.com"
}

# DNS validation records
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.main.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "cloudfront" {
  provider = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

module "waf_cloudfront" {
  source = "../../"

  # WAF Configuration for CloudFront
  waf_web_acl_name        = "cloudfront-waf-example"
  waf_web_acl_description = "WAF configuration for CloudFront distribution"
  waf_scope               = "CLOUDFRONT"  # Must be CLOUDFRONT for CloudFront
  default_action          = "allow"

  # Enable security features
  enable_rate_limiting        = true
  rate_limit                  = 2000
  enable_aws_managed_rules    = true
  enable_sql_injection_protection = true
  enable_xss_protection       = true
  enable_ip_reputation_list   = true

  # Geo-blocking
  geo_block_countries = [
    "CN",  # China
    "RU",  # Russia
    "KP"   # North Korea
  ]

  # Custom rules for CloudFront
  custom_rules = [
    {
      name     = "BlockBadBots"
      priority = 10
      action   = "block"
      type     = "byte_match"
      search_string = "bad-bot"
      positional_constraint = "CONTAINS"
      field    = "header"
      header_name = "User-Agent"
      text_transformation = "LOWERCASE"
    },
    {
      name     = "BlockSuspiciousPaths"
      priority = 11
      action   = "block"
      type     = "byte_match"
      search_string = "/wp-admin"
      positional_constraint = "STARTS_WITH"
      field    = "uri_path"
      text_transformation = "LOWERCASE"
    }
  ]

  # CloudFront Configuration
  enable_cloudfront = true
  associate_waf_with_cloudfront = true

  cloudfront_enabled = true
  cloudfront_ipv6_enabled = true
  cloudfront_comment = "CloudFront distribution with WAF protection"
  cloudfront_default_root_object = "index.html"
  cloudfront_price_class = "PriceClass_100"

  # CloudFront Origins
  cloudfront_origins = [
    {
      domain_name = aws_s3_bucket.website.bucket_regional_domain_name
      origin_id   = "s3-website-origin"
      type        = "s3"
      custom_headers = [
        {
          name  = "X-Origin-Type"
          value = "S3-Website"
        }
      ]
    }
  ]

  # Default cache behavior
  cloudfront_default_cache_behavior = {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-website-origin"
    forward_query_string   = false
    forward_headers        = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    forward_cookies        = "none"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Ordered cache behaviors
  cloudfront_ordered_cache_behaviors = [
    {
      path_pattern           = "/api/*"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = "s3-website-origin"
      forward_query_string   = true
      forward_headers        = ["*"]
      forward_cookies        = "all"
      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = 0
      default_ttl            = 0
      max_ttl                = 0
    }
  ]

  # SSL/TLS Configuration
  cloudfront_use_default_certificate = false
  cloudfront_acm_certificate_arn     = aws_acm_certificate.cloudfront.arn
  cloudfront_ssl_support_method      = "sni-only"
  cloudfront_minimum_protocol_version = "TLSv1.2_2021"

  # Custom error responses
  cloudfront_custom_error_responses = [
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    },
    {
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    }
  ]

  # Aliases
  cloudfront_aliases = ["example.com", "www.example.com"]

  # Geo-restrictions
  cloudfront_geo_restriction_type = "blacklist"
  cloudfront_geo_restriction_locations = ["CN", "RU"]

  # Monitoring and logging
  enable_cloudwatch_metrics = true
  enable_sampled_requests   = true
  enable_waf_logging        = true
  waf_log_retention_days    = 90

  # Tags
  tags = {
    Environment = "production"
    Project     = "cloudfront-waf"
    Owner       = "devops-team"
    CostCenter  = "security"
  }
}

# Route53 A record for CloudFront
resource "aws_route53_record" "website" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "example.com"
  type    = "A"

  alias {
    name                   = module.waf_cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.waf_cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

# Route53 A record for www subdomain
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.example.com"
  type    = "A"

  alias {
    name                   = module.waf_cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.waf_cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
} 