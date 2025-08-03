# Terrascan Configuration for AWS WAF Module
# This file configures security scanning rules and policies

# Scan configuration
scan {
  # Scan all Terraform files
  path = "."
  
  # Include all policy types
  policy_types = ["aws", "terraform"]
  
  # Scan severity levels
  severity = ["HIGH", "MEDIUM", "LOW"]
  
  # Output format
  output_format = "json"
  
  # Include non-compliant resources
  include_non_compliant = true
  
  # Include passed resources
  include_passed = false
}

# Policy configuration
policy {
  # AWS WAF specific policies
  aws_wafv2_web_acl {
    # Ensure WAF logging is enabled
    logging_enabled = true
    
    # Ensure WAF has rules configured
    rules_configured = true
    
    # Ensure WAF is associated with resources
    associated_with_resources = true
  }
  
  # AWS CloudFront specific policies
  aws_cloudfront_distribution {
    # Ensure HTTPS is enforced
    https_enforced = true
    
    # Ensure security headers are configured
    security_headers_configured = true
    
    # Ensure WAF is associated
    waf_associated = true
  }
  
  # AWS ALB specific policies
  aws_lb {
    # Ensure deletion protection is enabled
    deletion_protection_enabled = true
    
    # Ensure access logs are enabled
    access_logs_enabled = true
    
    # Ensure WAF is associated
    waf_associated = true
  }
  
  # General AWS security policies
  aws_security {
    # Ensure encryption at rest
    encryption_at_rest_enabled = true
    
    # Ensure encryption in transit
    encryption_in_transit_enabled = true
    
    # Ensure least privilege access
    least_privilege_access = true
    
    # Ensure resource tagging
    resource_tagging_enabled = true
  }
}

# Exclude specific rules if needed
exclude {
  # Exclude specific rule IDs if they are false positives
  # rule_ids = ["AWS.CloudFront.EncryptionandKeyManagement.High.0401"]
}

# Custom policies (if needed)
custom_policy {
  # Example custom policy for WAF rate limiting
  waf_rate_limiting {
    description = "Ensure WAF has rate limiting configured"
    severity = "MEDIUM"
    
    condition {
      resource_type = "aws_wafv2_web_acl"
      attribute = "rule"
      operator = "contains"
      value = "rate_based_statement"
    }
  }
} 