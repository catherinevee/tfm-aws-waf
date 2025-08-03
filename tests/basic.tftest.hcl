# Basic WAF Module Tests
# This file contains basic validation tests for the WAF module

provider "aws" {
  region = "us-west-2"
}

# Test 1: Basic WAF deployment
run "waf_basic_deployment" {
  command = plan
  
  variables {
    waf_web_acl_name        = "test-basic-waf"
    waf_web_acl_description = "Test WAF for basic functionality"
    waf_scope               = "REGIONAL"
    default_action          = "allow"
    
    # Enable basic security features
    enable_rate_limiting        = true
    rate_limit                  = 1000
    enable_aws_managed_rules    = true
    enable_sql_injection_protection = true
    enable_xss_protection       = true
    enable_ip_reputation_list   = true
    
    # Basic monitoring
    enable_cloudwatch_metrics = true
    enable_sampled_requests   = true
    
    tags = {
      Environment = "test"
      Project     = "waf-testing"
    }
  }
  
  # Assertions
  assert {
    condition     = aws_wafv2_web_acl.main.name == "test-basic-waf"
    error_message = "WAF Web ACL name should match the input variable"
  }
  
  assert {
    condition     = aws_wafv2_web_acl.main.scope == "REGIONAL"
    error_message = "WAF scope should be REGIONAL"
  }
  
  assert {
    condition     = aws_wafv2_web_acl.main.capacity > 0
    error_message = "WAF Web ACL should have capacity greater than 0"
  }
  
  assert {
    condition     = length(aws_wafv2_web_acl.main.rule) >= 4
    error_message = "WAF should have at least 4 rules (rate limiting, AWS managed, SQL injection, XSS)"
  }
}

# Test 2: WAF with IP blocking
run "waf_with_ip_blocking" {
  command = plan
  
  variables {
    waf_web_acl_name = "test-ip-blocking-waf"
    waf_scope        = "REGIONAL"
    default_action   = "allow"
    
    # Enable IP blocking
    blocked_ip_addresses = [
      "192.168.1.100/32",
      "10.0.0.0/8"
    ]
    
    # Basic security
    enable_rate_limiting     = true
    enable_aws_managed_rules = true
    
    tags = {
      Environment = "test"
      Project     = "waf-testing"
    }
  }
  
  # Assertions
  assert {
    condition     = length(aws_wafv2_ip_set.blocked_ips) > 0
    error_message = "IP set should be created for blocked IP addresses"
  }
  
  assert {
    condition     = aws_wafv2_ip_set.blocked_ips[0].addresses[0] == "192.168.1.100/32"
    error_message = "First blocked IP should be 192.168.1.100/32"
  }
}

# Test 3: WAF with custom rules
run "waf_with_custom_rules" {
  command = plan
  
  variables {
    waf_web_acl_name = "test-custom-rules-waf"
    waf_scope        = "REGIONAL"
    default_action   = "allow"
    
    # Custom rules
    custom_rules = [
      {
        name     = "BlockAdminPath"
        priority = 10
        action   = "block"
        type     = "byte_match"
        search_string = "/admin"
        positional_constraint = "STARTS_WITH"
        field    = "uri_path"
        text_transformation = "LOWERCASE"
      },
      {
        name     = "BlockSuspiciousUserAgent"
        priority = 11
        action   = "block"
        type     = "byte_match"
        search_string = "bot"
        positional_constraint = "CONTAINS"
        field    = "header"
        header_name = "User-Agent"
        text_transformation = "LOWERCASE"
      }
    ]
    
    # Basic security
    enable_rate_limiting     = true
    enable_aws_managed_rules = true
    
    tags = {
      Environment = "test"
      Project     = "waf-testing"
    }
  }
  
  # Assertions
  assert {
    condition     = length(aws_wafv2_web_acl.main.rule) >= 4
    error_message = "WAF should have at least 4 rules (rate limiting, AWS managed, and 2 custom rules)"
  }
}

# Test 4: WAF with CloudFront scope
run "waf_cloudfront_scope" {
  command = plan
  
  variables {
    waf_web_acl_name = "test-cloudfront-waf"
    waf_scope        = "CLOUDFRONT"
    default_action   = "allow"
    
    # Basic security
    enable_rate_limiting     = true
    enable_aws_managed_rules = true
    
    tags = {
      Environment = "test"
      Project     = "waf-testing"
    }
  }
  
  # Assertions
  assert {
    condition     = aws_wafv2_web_acl.main.scope == "CLOUDFRONT"
    error_message = "WAF scope should be CLOUDFRONT"
  }
}

# Test 5: WAF with logging enabled
run "waf_with_logging" {
  command = plan
  
  variables {
    waf_web_acl_name = "test-logging-waf"
    waf_scope        = "REGIONAL"
    default_action   = "allow"
    
    # Enable logging
    enable_waf_logging = true
    waf_log_retention_days = 30
    
    # Basic security
    enable_rate_limiting     = true
    enable_aws_managed_rules = true
    
    tags = {
      Environment = "test"
      Project     = "waf-testing"
    }
  }
  
  # Assertions
  assert {
    condition     = length(aws_cloudwatch_log_group.waf) > 0
    error_message = "CloudWatch log group should be created for WAF logging"
  }
  
  assert {
    condition     = aws_cloudwatch_log_group.waf[0].retention_in_days == 30
    error_message = "Log retention should be set to 30 days"
  }
}

# Test 6: Variable validation
run "variable_validation" {
  command = plan
  
  variables {
    waf_web_acl_name = "test-validation"
    waf_scope        = "REGIONAL"
    default_action   = "allow"
    rate_limit       = 500
    
    # Basic security
    enable_rate_limiting     = true
    enable_aws_managed_rules = true
    
    tags = {
      Environment = "test"
      Project     = "waf-testing"
    }
  }
  
  # Assertions for variable validation
  assert {
    condition     = var.rate_limit >= 100 && var.rate_limit <= 2000000
    error_message = "Rate limit should be within valid range (100-2,000,000)"
  }
  
  assert {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.waf_scope)
    error_message = "WAF scope should be either REGIONAL or CLOUDFRONT"
  }
  
  assert {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Default action should be either allow or block"
  }
} 