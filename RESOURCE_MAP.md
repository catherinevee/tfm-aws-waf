# AWS WAF + CloudFront/ALB Module - Resource Map

This document provides a comprehensive overview of all AWS resources created by the `tfm-aws-waf` Terraform module, organized by functional category.

## 🛡️ WAF (Web Application Firewall) Resources

### Core WAF Resources
| Resource | Type | Description | Dependencies |
|----------|------|-------------|--------------|
| `aws_wafv2_web_acl.main` | WAF Web ACL | Main WAF Web Access Control List with configurable rules | None |
| `aws_wafv2_ip_set.blocked_ips` | WAF IP Set | IP addresses and CIDR ranges to block | None |

### WAF Logging & Monitoring
| Resource | Type | Description | Dependencies |
|----------|------|-------------|--------------|
| `aws_cloudwatch_log_group.waf` | CloudWatch Log Group | Log group for WAF logs | None |
| `aws_kinesis_firehose_delivery_stream.waf_logs` | Kinesis Firehose | Delivery stream for WAF logs to S3 | `aws_iam_role.firehose_role` |
| `aws_iam_role.firehose_role` | IAM Role | Role for Kinesis Firehose to write to S3 | None |
| `aws_iam_role_policy.firehose_policy` | IAM Policy | Policy for Firehose role permissions | `aws_iam_role.firehose_role` |
| `aws_wafv2_web_acl_logging_configuration.main` | WAF Logging Config | Configuration for WAF logging | `aws_wafv2_web_acl.main`, `aws_kinesis_firehose_delivery_stream.waf_logs` |

## ☁️ CloudFront Resources

### Distribution & Configuration
| Resource | Type | Description | Dependencies |
|----------|------|-------------|--------------|
| `aws_cloudfront_distribution.main` | CloudFront Distribution | Global CDN distribution with configurable origins | `aws_wafv2_web_acl.main` (if WAF association enabled) |

## ⚖️ Application Load Balancer Resources

### Load Balancer Components
| Resource | Type | Description | Dependencies |
|----------|------|-------------|--------------|
| `aws_lb.main` | Application Load Balancer | Regional load balancer for traffic distribution | None |
| `aws_lb_target_group.main` | ALB Target Group | Target group for backend services | None |
| `aws_lb_listener.main` | ALB Listener | Listener for handling incoming traffic | `aws_lb.main`, `aws_lb_target_group.main` |

### WAF Integration
| Resource | Type | Description | Dependencies |
|----------|------|-------------|--------------|
| `aws_wafv2_web_acl_association.alb` | WAF Association | Associates WAF Web ACL with ALB | `aws_wafv2_web_acl.main`, `aws_lb.main` |

## 📊 Resource Categories Summary

### Security Resources
- **WAF Web ACL**: Main security control point
- **WAF IP Sets**: IP-based blocking capabilities
- **WAF Logging**: Comprehensive security monitoring

### Networking Resources
- **CloudFront Distribution**: Global content delivery
- **Application Load Balancer**: Regional traffic distribution
- **ALB Target Groups**: Backend service definitions

### Monitoring & Logging Resources
- **CloudWatch Log Groups**: Centralized logging
- **Kinesis Firehose**: Log delivery to S3
- **IAM Roles & Policies**: Secure access management

### Integration Resources
- **WAF Associations**: Security integration with ALB/CloudFront
- **Logging Configurations**: Monitoring setup

## 🔗 Resource Dependencies

### Primary Dependencies
```
aws_wafv2_web_acl.main
├── aws_wafv2_ip_set.blocked_ips (if IP blocking enabled)
├── aws_cloudfront_distribution.main (if CloudFront enabled)
├── aws_wafv2_web_acl_association.alb (if ALB enabled)
└── aws_wafv2_web_acl_logging_configuration.main (if logging enabled)
    ├── aws_cloudwatch_log_group.waf
    ├── aws_kinesis_firehose_delivery_stream.waf_logs
    │   └── aws_iam_role.firehose_role
    │       └── aws_iam_role_policy.firehose_policy
    └── aws_wafv2_web_acl.main
```

### Conditional Resources
- **CloudFront Resources**: Only created when `enable_cloudfront = true`
- **ALB Resources**: Only created when `enable_alb = true`
- **WAF Logging**: Only created when `enable_waf_logging = true`
- **Kinesis Firehose**: Only created when `enable_kinesis_firehose = true`

## 🏷️ Tagging Strategy

All resources support consistent tagging through the `tags` variable, ensuring:
- **Cost Allocation**: Resources can be grouped by project, environment, or team
- **Security Compliance**: Resources are properly categorized for security policies
- **Operational Management**: Easy identification and management of related resources

## 📈 Scaling Considerations

### WAF Capacity
- Web ACL capacity is automatically managed by AWS
- Rate limiting rules can be adjusted based on traffic patterns
- IP sets can be updated dynamically without recreating resources

### CloudFront Scaling
- Automatically scales to handle global traffic
- Edge locations provide low-latency access worldwide
- Cache behaviors can be optimized for different content types

### ALB Scaling
- Supports auto-scaling groups for backend services
- Health checks ensure only healthy targets receive traffic
- Multiple availability zones provide high availability

## 🔒 Security Features

### WAF Protection
- **Rate Limiting**: Prevents DDoS attacks
- **AWS Managed Rules**: Industry-standard security rules
- **SQL Injection Protection**: Blocks malicious database queries
- **XSS Protection**: Prevents cross-site scripting attacks
- **IP Reputation Lists**: Blocks known malicious IPs
- **Geo-blocking**: Restricts access by country
- **Custom Rules**: Application-specific security rules

### Network Security
- **HTTPS Enforcement**: Secure communication protocols
- **Security Groups**: Network-level access controls
- **SSL/TLS Termination**: Certificate management
- **Access Logging**: Comprehensive audit trails

## 💰 Cost Optimization

### Resource Optimization
- **CloudFront**: Reduces origin server costs through caching
- **WAF**: Pay-per-request pricing model
- **ALB**: Pay-per-hour with data processing fees
- **Logging**: Configurable retention periods to control storage costs

### Monitoring Costs
- **CloudWatch Metrics**: Basic metrics included, custom metrics incur charges
- **Kinesis Firehose**: Pay-per-data volume processed
- **S3 Storage**: Pay-per-GB stored for logs

## 🚀 Performance Considerations

### WAF Performance
- **Rule Priority**: Optimize rule order for performance
- **IP Set Size**: Large IP sets may impact performance
- **Rate Limiting**: Balance security with legitimate traffic

### CloudFront Performance
- **Cache Hit Ratio**: Optimize cache behaviors for better performance
- **Origin Response**: Minimize origin response times
- **Edge Locations**: Choose appropriate price class for global coverage

### ALB Performance
- **Target Health**: Maintain healthy target groups
- **Connection Draining**: Graceful handling of target changes
- **Cross-Zone Load Balancing**: Distribute traffic across AZs 