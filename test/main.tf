# Test configuration for WAF module

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

module "waf_test" {
  source = "../"

  # Basic WAF configuration for testing
  waf_web_acl_name        = "test-waf-web-acl"
  waf_web_acl_description = "Test WAF configuration"
  waf_scope               = "REGIONAL"
  default_action          = "allow"

  # Enable basic security features
  enable_rate_limiting        = true
  rate_limit                  = 100
  enable_aws_managed_rules    = true
  enable_sql_injection_protection = true
  enable_xss_protection       = true
  enable_ip_reputation_list   = true

  # Test blocked IP addresses
  blocked_ip_addresses = [
    "192.168.1.100/32"
  ]

  # Test geo-blocking
  geo_block_countries = [
    "CN"
  ]

  # Test custom rules
  custom_rules = [
    {
      name     = "TestBlockRule"
      priority = 10
      action   = "block"
      type     = "byte_match"
      search_string = "/test"
      positional_constraint = "STARTS_WITH"
      field    = "uri_path"
      text_transformation = "LOWERCASE"
    }
  ]

  # Monitoring and logging
  enable_cloudwatch_metrics = true
  enable_sampled_requests   = true
  enable_waf_logging        = true
  waf_log_retention_days    = 7

  # Tags for testing
  tags = {
    Environment = "test"
    Project     = "waf-test"
    Owner       = "test-team"
  }
} 