# Test outputs

output "waf_web_acl_id" {
  description = "ID of the test WAF Web ACL"
  value       = module.waf_test.waf_web_acl_id
}

output "waf_web_acl_arn" {
  description = "ARN of the test WAF Web ACL"
  value       = module.waf_test.waf_web_acl_arn
}

output "waf_web_acl_name" {
  description = "Name of the test WAF Web ACL"
  value       = module.waf_test.waf_web_acl_name
}

output "waf_ip_set_id" {
  description = "ID of the test WAF IP Set"
  value       = module.waf_test.waf_ip_set_id
}

output "waf_log_group_name" {
  description = "Name of the test CloudWatch log group"
  value       = module.waf_test.waf_log_group_name
}

output "waf_web_acl_rules" {
  description = "List of test WAF Web ACL rules"
  value       = module.waf_test.waf_web_acl_rules
}

output "resource_summary" {
  description = "Summary of test resources"
  value       = module.waf_test.resource_summary
} 