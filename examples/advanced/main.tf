# Advanced WAF Example
# This example demonstrates comprehensive WAF configuration with all features enabled

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
  region = "us-west-2"
}

# S3 bucket for WAF logs
resource "aws_s3_bucket" "waf_logs" {
  bucket = "waf-logs-${random_string.bucket_suffix.result}"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy for WAF logging
resource "aws_s3_bucket_policy" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowWAFLogging"
        Effect    = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.waf_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid       = "AllowWAFLoggingAcl"
        Effect    = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.waf_logs.arn
      }
    ]
  })
}

# CloudWatch Log Group for WAF metrics
resource "aws_cloudwatch_log_group" "waf_metrics" {
  name              = "/aws/waf/metrics"
  retention_in_days = 90
}

# CloudWatch Dashboard for WAF monitoring
resource "aws_cloudwatch_dashboard" "waf_dashboard" {
  dashboard_name = "WAF-Security-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/WAFV2", "BlockedRequests", "WebACL", "waf-advanced-example"],
            ["AWS/WAFV2", "AllowedRequests", "WebACL", "waf-advanced-example"],
            ["AWS/WAFV2", "SampledRequests", "WebACL", "waf-advanced-example"]
          ]
          period = 300
          stat   = "Sum"
          region = "us-west-2"
          title  = "WAF Requests"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/WAFV2", "BlockedRequests", "Rule", "RateLimitRule"],
            ["AWS/WAFV2", "BlockedRequests", "Rule", "SQLInjectionRule"],
            ["AWS/WAFV2", "BlockedRequests", "Rule", "XSSProtectionRule"]
          ]
          period = 300
          stat   = "Sum"
          region = "us-west-2"
          title  = "WAF Rule Blocks"
        }
      }
    ]
  })
}

# CloudWatch Alarms for WAF monitoring
resource "aws_cloudwatch_metric_alarm" "waf_high_block_rate" {
  alarm_name          = "waf-high-block-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "This metric monitors WAF blocked requests"
  alarm_actions       = []

  dimensions = {
    WebACL = "waf-advanced-example"
  }
}

resource "aws_cloudwatch_metric_alarm" "waf_rate_limit_exceeded" {
  alarm_name          = "waf-rate-limit-exceeded"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "50"
  alarm_description   = "This metric monitors WAF rate limit blocks"
  alarm_actions       = []

  dimensions = {
    Rule = "RateLimitRule"
  }
}

module "waf_advanced" {
  source = "../../"

  # WAF Configuration
  waf_web_acl_name        = "waf-advanced-example"
  waf_web_acl_description = "Advanced WAF configuration with comprehensive security features"
  waf_scope               = "REGIONAL"
  default_action          = "allow"

  # Enhanced security features
  enable_rate_limiting        = true
  rate_limit                  = 500
  enable_aws_managed_rules    = true
  enable_sql_injection_protection = true
  enable_xss_protection       = true
  enable_ip_reputation_list   = true

  # Comprehensive IP blocking
  blocked_ip_addresses = [
    "192.168.1.100/32",
    "10.0.0.0/8",
    "172.16.0.0/12",
    "203.0.113.0/24"
  ]

  # Extensive geo-blocking
  geo_block_countries = [
    "CN",  # China
    "RU",  # Russia
    "KP",  # North Korea
    "IR",  # Iran
    "SY",  # Syria
    "CU"   # Cuba
  ]

  # Advanced custom rules
  custom_rules = [
    {
      name     = "BlockAdminAccess"
      priority = 10
      action   = "block"
      type     = "byte_match"
      search_string = "/admin"
      positional_constraint = "STARTS_WITH"
      field    = "uri_path"
      text_transformation = "LOWERCASE"
    },
    {
      name     = "BlockSuspiciousUserAgents"
      priority = 11
      action   = "block"
      type     = "byte_match"
      search_string = "bot|scanner|crawler|spider"
      positional_constraint = "CONTAINS"
      field    = "header"
      header_name = "User-Agent"
      text_transformation = "LOWERCASE"
    },
    {
      name     = "BlockSQLInjectionAttempts"
      priority = 12
      action   = "block"
      type     = "byte_match"
      search_string = "union select|drop table|insert into|delete from"
      positional_constraint = "CONTAINS"
      field    = "query_string"
      text_transformation = "LOWERCASE"
    },
    {
      name     = "BlockXSSAttempts"
      priority = 13
      action   = "block"
      type     = "byte_match"
      search_string = "<script|javascript:|onload=|onerror="
      positional_constraint = "CONTAINS"
      field    = "query_string"
      text_transformation = "LOWERCASE"
    },
    {
      name     = "BlockPathTraversal"
      priority = 14
      action   = "block"
      type     = "byte_match"
      search_string = "../|..\\|%2e%2e%2f|%2e%2e%5c"
      positional_constraint = "CONTAINS"
      field    = "uri_path"
      text_transformation = "URL_DECODE"
    },
    {
      name     = "BlockSuspiciousHeaders"
      priority = 15
      action   = "block"
      type     = "byte_match"
      search_string = "x-forwarded-for|x-real-ip|x-client-ip"
      positional_constraint = "CONTAINS"
      field    = "header"
      header_name = "X-Forwarded-For"
      text_transformation = "LOWERCASE"
    }
  ]

  # Enhanced monitoring and logging
  enable_cloudwatch_metrics = true
  enable_sampled_requests   = true
  enable_waf_logging        = true
  waf_log_retention_days    = 90
  enable_kinesis_firehose   = true
  waf_logs_s3_bucket_arn    = aws_s3_bucket.waf_logs.arn

  # WAF logging filters
  waf_logging_filters = {
    default_behavior = "KEEP"
    filters = [
      {
        behavior         = "KEEP"
        condition_action = "BLOCK"
        requirement      = "MEETS_ANY"
      },
      {
        behavior         = "KEEP"
        condition_action = "RATE_BASED"
        requirement      = "MEETS_ANY"
      }
    ]
  }

  # Tags for advanced tracking
  tags = {
    Environment = "production"
    Project     = "waf-advanced"
    Owner       = "security-team"
    CostCenter  = "security"
    Compliance  = "SOC2"
    DataClass   = "confidential"
    Backup      = "true"
    Monitoring  = "true"
  }
}

# Output the WAF configuration for verification
output "waf_configuration" {
  description = "Complete WAF configuration details"
  value = {
    web_acl_id   = module.waf_advanced.waf_web_acl_id
    web_acl_arn  = module.waf_advanced.waf_web_acl_arn
    web_acl_name = module.waf_advanced.waf_web_acl_name
    capacity     = module.waf_advanced.waf_web_acl_capacity
    rules        = module.waf_advanced.waf_web_acl_rules
    logging      = module.waf_advanced.waf_logging_configuration
  }
}

# Output monitoring resources
output "monitoring_resources" {
  description = "Monitoring and logging resources"
  value = {
    log_group_name = module.waf_advanced.waf_log_group_name
    log_group_arn  = module.waf_advanced.waf_log_group_arn
    firehose_name  = module.waf_advanced.waf_firehose_delivery_stream_name
    firehose_arn   = module.waf_advanced.waf_firehose_delivery_stream_arn
    s3_bucket_name = aws_s3_bucket.waf_logs.bucket
    s3_bucket_arn  = aws_s3_bucket.waf_logs.arn
    dashboard_name = aws_cloudwatch_dashboard.waf_dashboard.dashboard_name
  }
}

# Output security summary
output "security_summary" {
  description = "Security configuration summary"
  value = {
    total_rules_enabled = length(module.waf_advanced.waf_web_acl_rules)
    blocked_ips_count   = length(module.waf_advanced.waf_web_acl_rules.blocked_ips_count)
    geo_blocked_countries = module.waf_advanced.waf_web_acl_rules.geo_blocked_countries
    custom_rules_count  = module.waf_advanced.waf_web_acl_rules.custom_rules_count
    logging_enabled     = module.waf_advanced.waf_logging_configuration.logging_enabled
    firehose_enabled    = module.waf_advanced.waf_logging_configuration.kinesis_firehose_enabled
  }
} 