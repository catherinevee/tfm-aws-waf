# Comprehensive WAF Module Tests
# This file contains comprehensive validation tests for the WAF module

provider "aws" {
  region = "us-west-2"
}

# Test 1: Full deployment with all features enabled
run "full_deployment" {
  command = apply

  variables {
    waf_web_acl_name        = "test-comprehensive-waf"
    waf_web_acl_description = "Test WAF for comprehensive functionality"
    waf_scope               = "REGIONAL"
    default_action          = "allow"
    enable_rate_limiting    = true
    rate_limit              = 1000
    enable_aws_managed_rules = true
    enable_sql_injection_protection = true
    enable_xss_protection   = true
    enable_ip_reputation_list = true
    blocked_ip_addresses    = ["192.168.1.1/32", "10.0.0.0/8"]
    geo_block_countries     = ["CN", "RU"]
    enable_cloudwatch_metrics = true
    enable_sampled_requests = true
    enable_waf_logging      = true
    waf_log_retention_days  = 30
    enable_alb             = true
    alb_name               = "test-alb"
    alb_internal           = false
    alb_vpc_id             = "vpc-12345678"
    alb_subnets            = ["subnet-12345678", "subnet-87654321"]
    alb_security_groups    = ["sg-12345678"]
    tags = {
      Environment = "test"
      Project     = "waf-testing"
    }
  }

  # Assertions for WAF
  assert {
    condition     = aws_wafv2_web_acl.main.name == "test-comprehensive-waf"
    error_message = "WAF Web ACL name should match the input variable"
  }

  assert {
    condition     = aws_wafv2_web_acl.main.scope == "REGIONAL"
    error_message = "WAF Web ACL scope should be REGIONAL"
  }

  assert {
    condition     = aws_wafv2_web_acl.main.capacity > 0
    error_message = "WAF Web ACL should have capacity > 0"
  }

  # Assertions for ALB
  assert {
    condition     = aws_lb.main[0].name == "test-alb"
    error_message = "ALB name should match the input variable"
  }

  assert {
    condition     = aws_lb.main[0].internal == false
    error_message = "ALB should be internet-facing by default"
  }

  # Assertions for IP Set
  assert {
    condition     = length(aws_wafv2_ip_set.blocked_ips) > 0
    error_message = "IP set should be created for blocked IPs"
  }
}

# Test 2: Security validation with strict settings
run "security_validation" {
  command = plan

  variables {
    waf_web_acl_name        = "test-security-waf"
    waf_web_acl_description = "Test WAF for security validation"
    waf_scope               = "REGIONAL"
    default_action          = "block"
    enable_rate_limiting    = true
    rate_limit              = 100
    blocked_ip_addresses    = ["192.168.1.1/32", "10.0.0.0/8", "172.16.0.0/12"]
    geo_block_countries     = ["CN", "RU", "KP"]
    enable_aws_managed_rules = true
    enable_sql_injection_protection = true
    enable_xss_protection   = true
    enable_ip_reputation_list = true
    enable_cloudwatch_metrics = true
    enable_sampled_requests = true
    enable_waf_logging      = true
    waf_log_retention_days  = 90
    tags = {
      Environment = "production"
      Security    = "high"
    }
  }

  # Security assertions
  assert {
    condition     = aws_wafv2_web_acl.main.default_action[0].block != null
    error_message = "WAF should be configured with block as default action for security"
  }

  assert {
    condition     = var.rate_limit <= 100
    error_message = "Rate limit should be set to a low value for security testing"
  }

  assert {
    condition     = length(var.blocked_ip_addresses) >= 3
    error_message = "Should have multiple blocked IP ranges for security"
  }

  assert {
    condition     = length(var.geo_block_countries) >= 3
    error_message = "Should have multiple geo-blocked countries for security"
  }
}

# Test 3: CloudFront scope validation
run "cloudfront_scope" {
  command = plan

  variables {
    waf_web_acl_name        = "test-cloudfront-waf"
    waf_web_acl_description = "Test WAF for CloudFront scope"
    waf_scope               = "CLOUDFRONT"
    default_action          = "allow"
    enable_cloudfront       = true
    cloudfront_enabled      = true
    cloudfront_comment      = "Test CloudFront distribution"
    cloudfront_origins = [
      {
        domain_name = "example.com"
        origin_id   = "test-origin"
      }
    ]
    cloudfront_default_cache_behavior = {
      target_origin_id       = "test-origin"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
    }
    tags = {
      Environment = "test"
      Service     = "cloudfront"
    }
  }

  # CloudFront assertions
  assert {
    condition     = aws_wafv2_web_acl.main.scope == "CLOUDFRONT"
    error_message = "WAF Web ACL scope should be CLOUDFRONT for CloudFront integration"
  }

  assert {
    condition     = aws_cloudfront_distribution.main[0].enabled == true
    error_message = "CloudFront distribution should be enabled"
  }

  assert {
    condition     = aws_cloudfront_distribution.main[0].comment == "Test CloudFront distribution"
    error_message = "CloudFront distribution comment should match input"
  }
}

# Test 4: Variable validation tests
run "variable_validation" {
  command = plan

  variables {
    waf_web_acl_name        = "test-validation-waf"
    waf_web_acl_description = "Test WAF for variable validation"
    waf_scope               = "REGIONAL"
    default_action          = "allow"
    rate_limit              = 500
    waf_log_retention_days  = 7
    tags = {
      Environment = "test"
      Validation  = "true"
    }
  }

  # Variable validation assertions
  assert {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.waf_web_acl_name))
    error_message = "WAF Web ACL name should contain only alphanumeric characters, hyphens, and underscores"
  }

  assert {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.waf_scope)
    error_message = "WAF scope should be either REGIONAL or CLOUDFRONT"
  }

  assert {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Default action should be either allow or block"
  }

  assert {
    condition     = var.rate_limit >= 100 && var.rate_limit <= 2000000
    error_message = "Rate limit should be between 100 and 2,000,000"
  }

  assert {
    condition     = var.waf_log_retention_days >= 1 && var.waf_log_retention_days <= 3653
    error_message = "WAF log retention days should be between 1 and 3653"
  }
}

# Test 5: Minimal configuration test
run "minimal_configuration" {
  command = plan

  variables {
    waf_web_acl_name        = "test-minimal-waf"
    waf_web_acl_description = "Test WAF with minimal configuration"
    waf_scope               = "REGIONAL"
    default_action          = "allow"
    enable_rate_limiting    = false
    enable_aws_managed_rules = false
    enable_sql_injection_protection = false
    enable_xss_protection   = false
    enable_ip_reputation_list = false
    enable_cloudwatch_metrics = false
    enable_sampled_requests = false
    enable_waf_logging      = false
    enable_cloudfront       = false
    enable_alb             = false
    tags = {}
  }

  # Minimal configuration assertions
  assert {
    condition     = aws_wafv2_web_acl.main.name == "test-minimal-waf"
    error_message = "WAF Web ACL name should match the input variable"
  }

  assert {
    condition     = aws_wafv2_web_acl.main.scope == "REGIONAL"
    error_message = "WAF Web ACL scope should be REGIONAL"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.main.rule) == 0
    error_message = "WAF Web ACL should have no rules in minimal configuration"
  }
}

# Test 6: Logging configuration test
run "logging_configuration" {
  command = plan

  variables {
    waf_web_acl_name        = "test-logging-waf"
    waf_web_acl_description = "Test WAF with logging configuration"
    waf_scope               = "REGIONAL"
    default_action          = "allow"
    enable_cloudwatch_metrics = true
    enable_sampled_requests = true
    enable_waf_logging      = true
    waf_log_retention_days  = 30
    enable_kinesis_firehose = true
    waf_logs_s3_bucket_arn  = "arn:aws:s3:::test-waf-logs-bucket"
    tags = {
      Environment = "test"
      Logging     = "enabled"
    }
  }

  # Logging assertions
  assert {
    condition     = aws_cloudwatch_log_group.waf[0].name == "/aws/waf/test-logging-waf"
    error_message = "CloudWatch log group name should match WAF name"
  }

  assert {
    condition     = aws_cloudwatch_log_group.waf[0].retention_in_days == 30
    error_message = "CloudWatch log group retention should match input"
  }

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.waf_logs[0].name == "test-logging-waf-waf-logs"
    error_message = "Kinesis Firehose delivery stream name should match WAF name"
  }
} 