# AWS WAF + CloudFront/ALB Module Outputs

# WAF Outputs
output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "waf_web_acl_name" {
  description = "Name of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.name
}

output "waf_web_acl_capacity" {
  description = "Capacity of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.capacity
}

output "waf_web_acl_scope" {
  description = "Scope of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.scope
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
  description = "ID of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].id : null
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].arn : null
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].domain_name : null
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].hosted_zone_id : null
}

output "cloudfront_distribution_status" {
  description = "Status of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].status : null
}

output "cloudfront_distribution_etag" {
  description = "ETag of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].etag : null
}

# ALB Outputs
output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = var.enable_alb ? aws_lb.main[0].id : null
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = var.enable_alb ? aws_lb.main[0].arn : null
}

output "alb_name" {
  description = "Name of the Application Load Balancer"
  value       = var.enable_alb ? aws_lb.main[0].name : null
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = var.enable_alb ? aws_lb.main[0].dns_name : null
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = var.enable_alb ? aws_lb.main[0].zone_id : null
}

output "alb_target_group_id" {
  description = "ID of the ALB target group"
  value       = var.enable_alb ? aws_lb_target_group.main[0].id : null
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