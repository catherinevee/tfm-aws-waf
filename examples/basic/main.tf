# Basic WAF Example
# This example demonstrates a simple WAF configuration without CloudFront or ALB

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

module "waf_basic" {
  source = "../../"

  # WAF Configuration
  waf_web_acl_name        = "basic-waf-example"
  waf_web_acl_description = "Basic WAF configuration for web application protection"
  waf_scope               = "REGIONAL"
  default_action          = "allow"

  # Enable basic security features
  enable_rate_limiting        = true
  rate_limit                  = 1000
  enable_aws_managed_rules    = true
  enable_sql_injection_protection = true
  enable_xss_protection       = true
  enable_ip_reputation_list   = true

  # Block specific IP addresses (example)
  blocked_ip_addresses = [
    "192.168.1.100/32",
    "10.0.0.0/8"
  ]

  # Geo-blocking (example)
  geo_block_countries = [
    "CN",  # China
    "RU"   # Russia
  ]

  # Custom rules (example)
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

  # Monitoring and logging
  enable_cloudwatch_metrics = true
  enable_sampled_requests   = true
  enable_waf_logging        = true
  waf_log_retention_days    = 30

  # Tags
  tags = {
    Environment = "development"
    Project     = "waf-example"
    Owner       = "devops-team"
    CostCenter  = "security"
  }
} 