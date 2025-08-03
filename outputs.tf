# AWS WAF + CloudFront/ALB Module Outputs

# WAF Outputs
output "waf_web_acl_id" {
  description = "The ID of the WAF Web ACL. Use this for WAF associations with CloudFront or ALB resources."
  value       = aws_wafv2_web_acl.main.id
  
  depends_on = [
    aws_wafv2_web_acl.main
  ]
}

output "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL. Required for associating with CloudFront distributions or ALB resources."
  value       = aws_wafv2_web_acl.main.arn
  
  depends_on = [
    aws_wafv2_web_acl.main
  ]
}

output "waf_web_acl_name" {
  description = "The name of the WAF Web ACL. Useful for resource identification and cost allocation."
  value       = aws_wafv2_web_acl.main.name
  
  depends_on = [
    aws_wafv2_web_acl.main
  ]
}

output "waf_web_acl_capacity" {
  description = "The capacity of the WAF Web ACL. This represents the number of rules that can be evaluated per request."
  value       = aws_wafv2_web_acl.main.capacity
  
  depends_on = [
    aws_wafv2_web_acl.main
  ]
}

output "waf_web_acl_scope" {
  description = "The scope of the WAF Web ACL (REGIONAL or CLOUDFRONT). Determines where the WAF can be associated."
  value       = aws_wafv2_web_acl.main.scope
  
  depends_on = [
    aws_wafv2_web_acl.main
  ]
}

# Composite WAF Configuration Output
output "waf_configuration" {
  description = "Complete WAF configuration for external consumption. Contains all essential WAF attributes in a structured format."
  value = {
    web_acl_id   = aws_wafv2_web_acl.main.id
    web_acl_arn  = aws_wafv2_web_acl.main.arn
    web_acl_name = aws_wafv2_web_acl.main.name
    scope        = aws_wafv2_web_acl.main.scope
    capacity     = aws_wafv2_web_acl.main.capacity
    description  = aws_wafv2_web_acl.main.description
    default_action = aws_wafv2_web_acl.main.default_action
  }
  
  depends_on = [
    aws_wafv2_web_acl.main
  ]
}

output "waf_ip_set_id" {
  description = "ID of the WAF IP Set for blocked IPs"
  value       = length(aws_wafv2_ip_set.blocked_ips) > 0 ? aws_wafv2_ip_set.blocked_ips[0].id : null
}

output "waf_ip_set_arn" {
  description = "ARN of the WAF IP Set for blocked IPs"
  value       = length(aws_wafv2_ip_set.blocked_ips) > 0 ? aws_wafv2_ip_set.blocked_ips[0].arn : null
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution. Use this for CloudFront-specific operations and monitoring."
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].id : null
  
  depends_on = [
    aws_cloudfront_distribution.main
  ]
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution. Required for IAM policies and cross-account access."
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].arn : null
  
  depends_on = [
    aws_cloudfront_distribution.main
  ]
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution. Use this for DNS configuration and application integration."
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].domain_name : null
  
  depends_on = [
    aws_cloudfront_distribution.main
  ]
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "The hosted zone ID of the CloudFront distribution. Required for Route 53 alias record configuration."
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].hosted_zone_id : null
  
  depends_on = [
    aws_cloudfront_distribution.main
  ]
}

output "cloudfront_distribution_status" {
  description = "The deployment status of the CloudFront distribution. Monitor this for deployment completion."
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].status : null
  
  depends_on = [
    aws_cloudfront_distribution.main
  ]
}

output "cloudfront_distribution_etag" {
  description = "The ETag of the CloudFront distribution. Used for change detection and version control."
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].etag : null
  
  depends_on = [
    aws_cloudfront_distribution.main
  ]
}

# Composite CloudFront Configuration Output
output "cloudfront_configuration" {
  description = "Complete CloudFront configuration for external consumption. Contains all essential CloudFront attributes."
  value = var.enable_cloudfront ? {
    distribution_id   = aws_cloudfront_distribution.main[0].id
    distribution_arn  = aws_cloudfront_distribution.main[0].arn
    domain_name       = aws_cloudfront_distribution.main[0].domain_name
    hosted_zone_id    = aws_cloudfront_distribution.main[0].hosted_zone_id
    status            = aws_cloudfront_distribution.main[0].status
    etag              = aws_cloudfront_distribution.main[0].etag
    enabled           = aws_cloudfront_distribution.main[0].enabled
    price_class       = aws_cloudfront_distribution.main[0].price_class
  } : null
  
  depends_on = [
    aws_cloudfront_distribution.main
  ]
}

# ALB Outputs
output "alb_id" {
  description = "The ID of the Application Load Balancer. Use this for ALB-specific operations and monitoring."
  value       = var.enable_alb ? aws_lb.main[0].id : null
  
  depends_on = [
    aws_lb.main
  ]
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer. Required for IAM policies and cross-account access."
  value       = var.enable_alb ? aws_lb.main[0].arn : null
  
  depends_on = [
    aws_lb.main
  ]
}

output "alb_name" {
  description = "The name of the Application Load Balancer. Useful for resource identification and cost allocation."
  value       = var.enable_alb ? aws_lb.main[0].name : null
  
  depends_on = [
    aws_lb.main
  ]
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer. Use this for DNS configuration and application integration."
  value       = var.enable_alb ? aws_lb.main[0].dns_name : null
  
  depends_on = [
    aws_lb.main
  ]
}

output "alb_zone_id" {
  description = "The zone ID of the Application Load Balancer. Required for Route 53 alias record configuration."
  value       = var.enable_alb ? aws_lb.main[0].zone_id : null
  
  depends_on = [
    aws_lb.main
  ]
}

output "alb_target_group_id" {
  description = "The ID of the ALB target group. Use this for target group operations and health check configuration."
  value       = var.enable_alb ? aws_lb_target_group.main[0].id : null
  
  depends_on = [
    aws_lb_target_group.main
  ]
}

# Composite ALB Configuration Output
output "alb_configuration" {
  description = "Complete ALB configuration for external consumption. Contains all essential ALB attributes."
  value = var.enable_alb ? {
    alb_id   = aws_lb.main[0].id
    alb_arn  = aws_lb.main[0].arn
    alb_name = aws_lb.main[0].name
    dns_name = aws_lb.main[0].dns_name
    zone_id  = aws_lb.main[0].zone_id
    internal = aws_lb.main[0].internal
    target_group_id = aws_lb_target_group.main[0].id
    target_group_arn = aws_lb_target_group.main[0].arn
  } : null
  
  depends_on = [
    aws_lb.main,
    aws_lb_target_group.main
  ]
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = var.enable_alb ? aws_lb_target_group.main[0].arn : null
}

output "alb_target_group_name" {
  description = "Name of the ALB target group"
  value       = var.enable_alb ? aws_lb_target_group.main[0].name : null
}

output "alb_listener_id" {
  description = "ID of the ALB listener"
  value       = var.enable_alb ? aws_lb_listener.main[0].id : null
}

output "alb_listener_arn" {
  description = "ARN of the ALB listener"
  value       = var.enable_alb ? aws_lb_listener.main[0].arn : null
}

# WAF Association Outputs
output "waf_alb_association_id" {
  description = "ID of the WAF-ALB association"
  value       = var.enable_alb && var.associate_waf_with_alb ? aws_wafv2_web_acl_association.alb[0].id : null
}

# Logging Outputs
output "waf_log_group_name" {
  description = "Name of the CloudWatch log group for WAF"
  value       = var.enable_waf_logging ? aws_cloudwatch_log_group.waf[0].name : null
}

output "waf_log_group_arn" {
  description = "ARN of the CloudWatch log group for WAF"
  value       = var.enable_waf_logging ? aws_cloudwatch_log_group.waf[0].arn : null
}

output "waf_firehose_delivery_stream_name" {
  description = "Name of the Kinesis Firehose delivery stream for WAF logs"
  value       = var.enable_waf_logging && var.enable_kinesis_firehose ? aws_kinesis_firehose_delivery_stream.waf_logs[0].name : null
}

output "waf_firehose_delivery_stream_arn" {
  description = "ARN of the Kinesis Firehose delivery stream for WAF logs"
  value       = var.enable_waf_logging && var.enable_kinesis_firehose ? aws_kinesis_firehose_delivery_stream.waf_logs[0].arn : null
}

output "waf_firehose_role_arn" {
  description = "ARN of the IAM role for Kinesis Firehose"
  value       = var.enable_waf_logging && var.enable_kinesis_firehose ? aws_iam_role.firehose_role[0].arn : null
}

# Security and Compliance Outputs
output "waf_web_acl_rules" {
  description = "List of WAF Web ACL rules"
  value = {
    rate_limiting_enabled     = var.enable_rate_limiting
    aws_managed_rules_enabled = var.enable_aws_managed_rules
    sql_injection_enabled     = var.enable_sql_injection_protection
    xss_protection_enabled    = var.enable_xss_protection
    ip_reputation_enabled     = var.enable_ip_reputation_list
    custom_rules_count        = length(var.custom_rules)
    blocked_ips_count         = length(var.blocked_ip_addresses)
    geo_blocked_countries     = var.geo_block_countries
  }
}

output "waf_logging_configuration" {
  description = "WAF logging configuration details"
  value = {
    logging_enabled           = var.enable_waf_logging
    cloudwatch_logging        = var.enable_waf_logging
    kinesis_firehose_enabled  = var.enable_kinesis_firehose
    log_retention_days        = var.waf_log_retention_days
    s3_bucket_arn            = var.waf_logs_s3_bucket_arn
  }
}

output "cloudfront_security_configuration" {
  description = "CloudFront security configuration details"
  value = var.enable_cloudfront ? {
    waf_enabled              = var.associate_waf_with_cloudfront
    ipv6_enabled             = var.cloudfront_ipv6_enabled
    minimum_protocol_version = var.cloudfront_minimum_protocol_version
    ssl_support_method       = var.cloudfront_ssl_support_method
    geo_restriction_type     = var.cloudfront_geo_restriction_type
    geo_restriction_locations = var.cloudfront_geo_restriction_locations
  } : null
}

output "alb_security_configuration" {
  description = "ALB security configuration details"
  value = var.enable_alb ? {
    waf_enabled              = var.associate_waf_with_alb
    internal                 = var.alb_internal
    deletion_protection      = var.alb_enable_deletion_protection
    http2_enabled            = var.alb_enable_http2
    security_groups          = var.alb_security_groups
    access_logging_enabled   = var.alb_access_logs_bucket != null
  } : null
}

# Resource Summary
output "resource_summary" {
  description = "Summary of all created resources"
  value = {
    waf_web_acl_created     = true
    cloudfront_created      = var.enable_cloudfront
    alb_created             = var.enable_alb
    waf_logging_enabled     = var.enable_waf_logging
    firehose_enabled        = var.enable_kinesis_firehose
    total_resources         = 1 + (var.enable_cloudfront ? 1 : 0) + (var.enable_alb ? 3 : 0) + (var.enable_waf_logging ? 1 : 0) + (var.enable_kinesis_firehose ? 3 : 0) + (length(var.blocked_ip_addresses) > 0 ? 1 : 0) + (var.enable_alb && var.associate_waf_with_alb ? 1 : 0)
  }
} 