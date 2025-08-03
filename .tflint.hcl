plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

config {
  module = true
  force  = false
}

# AWS Provider Configuration
rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_instance_invalid_ami" {
  enabled = true
}

rule "aws_instance_previous_type" {
  enabled = true
}

rule "aws_instance_invalid_key_name" {
  enabled = true
}

# WAF Specific Rules
rule "aws_wafv2_web_acl_invalid_name" {
  enabled = true
}

rule "aws_wafv2_web_acl_invalid_scope" {
  enabled = true
}

# CloudFront Specific Rules
rule "aws_cloudfront_distribution_invalid_price_class" {
  enabled = true
}

rule "aws_cloudfront_distribution_invalid_http_version" {
  enabled = true
}

# ALB Specific Rules
rule "aws_lb_invalid_name" {
  enabled = true
}

rule "aws_lb_invalid_type" {
  enabled = true
}

# General Terraform Rules
rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
} 