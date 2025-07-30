# Outputs for Basic WAF Example

output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = module.waf_basic.waf_web_acl_id
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = module.waf_basic.waf_web_acl_arn
}

output "waf_web_acl_name" {
  description = "Name of the WAF Web ACL"
  value       = module.waf_basic.waf_web_acl_name
}

output "waf_web_acl_capacity" {
  description = "Capacity of the WAF Web ACL"
  value       = module.waf_basic.waf_web_acl_capacity
}

output "waf_ip_set_id" {
  description = "ID of the WAF IP Set for blocked IPs"
  value       = module.waf_basic.waf_ip_set_id
}

output "waf_log_group_name" {
  description = "Name of the CloudWatch log group for WAF"
  value       = module.waf_basic.waf_log_group_name
}

output "waf_web_acl_rules" {
  description = "List of WAF Web ACL rules"
  value       = module.waf_basic.waf_web_acl_rules
}

output "waf_logging_configuration" {
  description = "WAF logging configuration details"
  value       = module.waf_basic.waf_logging_configuration
}

output "resource_summary" {
  description = "Summary of all created resources"
  value       = module.waf_basic.resource_summary
} 