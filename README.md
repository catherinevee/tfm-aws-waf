# AWS WAF + CloudFront/ALB Terraform Module

A comprehensive Terraform module for deploying AWS WAF (Web Application Firewall) with CloudFront distribution and Application Load Balancer (ALB) integration. This module provides enterprise-grade security features including rate limiting, SQL injection protection, XSS protection, IP reputation filtering, geo-blocking, and custom rules.

## Features

### 🛡️ WAF Security Features
- **Rate Limiting**: Configurable rate limiting per IP address
- **AWS Managed Rules**: Common rule set for general web application protection
- **SQL Injection Protection**: AWS managed SQL injection rule set
- **XSS Protection**: Cross-site scripting protection
- **IP Reputation Lists**: Block known malicious IP addresses
- **Custom IP Blocking**: Block specific IP addresses or CIDR ranges
- **Geo-blocking**: Block traffic from specific countries
- **Custom Rules**: Define custom byte-match rules for specific requirements

### ☁️ CloudFront Integration
- **Global CDN**: Content delivery network with edge locations worldwide
- **SSL/TLS Support**: HTTPS enforcement with configurable minimum protocol versions
- **Custom Origins**: Support for S3, ALB, and custom origins
- **Cache Behaviors**: Configurable caching rules and TTL settings
- **Lambda@Edge**: Support for Lambda function associations
- **Geo-restrictions**: Country-based access control

### ⚖️ Application Load Balancer
- **Load Balancing**: Distribute traffic across multiple targets
- **Health Checks**: Configurable health check settings
- **SSL/TLS Termination**: HTTPS support with certificate management
- **Access Logging**: S3-based access logging
- **Security Groups**: Network-level security controls

### 📊 Monitoring & Logging
- **CloudWatch Metrics**: Real-time monitoring of WAF rules
- **WAF Logging**: Detailed logging to CloudWatch or S3 via Kinesis Firehose
- **Sampled Requests**: Request sampling for analysis
- **Log Retention**: Configurable log retention periods

## Usage

### Basic WAF Only

```hcl
module "waf" {
  source = "./tfm-aws-waf"

  waf_web_acl_name        = "my-waf-web-acl"
  waf_web_acl_description = "WAF for my web application"
  
  # Enable basic security features
  enable_rate_limiting        = true
  enable_aws_managed_rules    = true
  enable_sql_injection_protection = true
  enable_xss_protection       = true
  enable_ip_reputation_list   = true
  
  # Block specific IP addresses
  blocked_ip_addresses = ["192.168.1.100/32", "10.0.0.0/8"]
  
  # Geo-blocking
  geo_block_countries = ["CN", "RU"]
  
  tags = {
    Environment = "production"
    Project     = "web-app"
  }
}
```

### WAF with CloudFront

```hcl
module "waf_cloudfront" {
  source = "./tfm-aws-waf"

  # WAF Configuration
  waf_web_acl_name = "cloudfront-waf"
  waf_scope        = "CLOUDFRONT"
  
  # Enable CloudFront
  enable_cloudfront = true
  associate_waf_with_cloudfront = true
  
  # CloudFront Configuration
  cloudfront_origins = [
    {
      domain_name = "my-s3-bucket.s3.amazonaws.com"
      origin_id   = "s3-origin"
      type        = "s3"
    }
  ]
  
  cloudfront_default_cache_behavior = {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-origin"
    forward_query_string   = false
    forward_headers        = []
    forward_cookies        = "none"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  
  # Security settings
  cloudfront_minimum_protocol_version = "TLSv1.2_2021"
  cloudfront_use_default_certificate  = false
  cloudfront_acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  
  tags = {
    Environment = "production"
    Service     = "cdn"
  }
}
```

### WAF with ALB

```hcl
module "waf_alb" {
  source = "./tfm-aws-waf"

  # WAF Configuration
  waf_web_acl_name = "alb-waf"
  waf_scope        = "REGIONAL"
  
  # Enable ALB
  enable_alb = true
  associate_waf_with_alb = true
  
  # ALB Configuration
  alb_name = "my-application-lb"
  alb_subnets = ["subnet-12345678", "subnet-87654321"]
  alb_security_groups = ["sg-12345678"]
  alb_vpc_id = "vpc-12345678"
  
  # ALB Target Group
  alb_target_group_name = "my-target-group"
  alb_target_group_port = 80
  alb_target_group_protocol = "HTTP"
  
  # Health Check
  alb_health_check = {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  
  # Listener
  alb_listener_port = 443
  alb_listener_protocol = "HTTPS"
  alb_listener_ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  alb_listener_certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/example"
  
  tags = {
    Environment = "production"
    Service     = "web-app"
  }
}
```

### Advanced Configuration with Custom Rules

```hcl
module "waf_advanced" {
  source = "./tfm-aws-waf"

  waf_web_acl_name = "advanced-waf"
  
  # Custom WAF Rules
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
  
  # Enhanced logging
  enable_waf_logging = true
  waf_log_retention_days = 90
  enable_kinesis_firehose = true
  waf_logs_s3_bucket_arn = "arn:aws:s3:::my-waf-logs-bucket"
  
  # Rate limiting
  rate_limit = 1000
  
  tags = {
    Environment = "production"
    Security    = "high"
  }
}
```

## Inputs

### WAF Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| waf_web_acl_name | Name of the WAF Web ACL | `string` | `"waf-web-acl"` | no |
| waf_web_acl_description | Description of the WAF Web ACL | `string` | `"WAF Web ACL for protecting web applications"` | no |
| waf_scope | Scope of the WAF Web ACL (REGIONAL or CLOUDFRONT) | `string` | `"REGIONAL"` | no |
| default_action | Default action for the WAF Web ACL (allow or block) | `string` | `"allow"` | no |

### WAF Rules

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_rate_limiting | Enable rate limiting rule | `bool` | `true` | no |
| rate_limit | Rate limit for requests per 5 minutes | `number` | `2000` | no |
| enable_aws_managed_rules | Enable AWS managed rules | `bool` | `true` | no |
| enable_sql_injection_protection | Enable SQL injection protection | `bool` | `true` | no |
| enable_xss_protection | Enable XSS protection | `bool` | `true` | no |
| enable_ip_reputation_list | Enable IP reputation list protection | `bool` | `true` | no |
| blocked_ip_addresses | List of IP addresses to block | `list(string)` | `[]` | no |
| geo_block_countries | List of country codes to block | `list(string)` | `[]` | no |
| custom_rules | List of custom WAF rules | `list(object)` | `[]` | no |

### CloudFront Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_cloudfront | Enable CloudFront distribution | `bool` | `false` | no |
| cloudfront_origins | List of CloudFront origins | `list(object)` | `[]` | no |
| cloudfront_default_cache_behavior | Default cache behavior for CloudFront | `object` | See variables.tf | no |
| cloudfront_aliases | Aliases for CloudFront distribution | `list(string)` | `[]` | no |

### ALB Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_alb | Enable Application Load Balancer | `bool` | `false` | no |
| alb_name | Name of the Application Load Balancer | `string` | `"alb"` | no |
| alb_subnets | Subnets for the ALB | `list(string)` | `[]` | no |
| alb_security_groups | Security groups for the ALB | `list(string)` | `[]` | no |
| alb_vpc_id | VPC ID for the ALB target group | `string` | `null` | no |

### Logging and Monitoring

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_waf_logging | Enable WAF logging | `bool` | `true` | no |
| waf_log_retention_days | Number of days to retain WAF logs | `number` | `30` | no |
| enable_kinesis_firehose | Enable Kinesis Firehose for WAF logs | `bool` | `false` | no |
| enable_cloudwatch_metrics | Enable CloudWatch metrics for WAF rules | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| waf_web_acl_id | ID of the WAF Web ACL |
| waf_web_acl_arn | ARN of the WAF Web ACL |
| cloudfront_distribution_id | ID of the CloudFront distribution |
| cloudfront_distribution_domain_name | Domain name of the CloudFront distribution |
| alb_id | ID of the Application Load Balancer |
| alb_dns_name | DNS name of the Application Load Balancer |
| waf_log_group_name | Name of the CloudWatch log group for WAF |
| waf_web_acl_rules | List of WAF Web ACL rules |
| resource_summary | Summary of all created resources |

## Examples

See the `examples/` directory for complete working examples:

- `examples/basic/` - Basic WAF configuration
- `examples/cloudfront/` - WAF with CloudFront integration
- `examples/alb/` - WAF with ALB integration
- `examples/advanced/` - Advanced configuration with custom rules

## Resource Map

For a detailed overview of all AWS resources created by this module, see [RESOURCE_MAP.md](RESOURCE_MAP.md).

## Security Best Practices

1. **Enable All Security Rules**: Use all available AWS managed rules for comprehensive protection
2. **Rate Limiting**: Set appropriate rate limits based on your application's expected traffic
3. **IP Blocking**: Regularly update blocked IP lists based on security intelligence
4. **Geo-blocking**: Block traffic from countries where you don't operate
5. **Logging**: Enable comprehensive logging for security monitoring and incident response
6. **Custom Rules**: Implement custom rules based on your application's specific security requirements
7. **Regular Updates**: Keep WAF rules and configurations up to date

## Cost Optimization

1. **CloudFront Price Classes**: Choose appropriate price classes based on your global reach
2. **Log Retention**: Set appropriate log retention periods to balance cost and compliance
3. **Kinesis Firehose**: Only enable when you need advanced log processing
4. **WAF Capacity**: Monitor WAF capacity and optimize rule configurations

## Troubleshooting

### Common Issues

1. **WAF Capacity Exceeded**: Reduce the number of rules or optimize rule configurations
2. **CloudFront Distribution Not Deployed**: Check origin configurations and certificate validity
3. **ALB Health Check Failures**: Verify target group health check settings and backend availability
4. **Logging Issues**: Ensure proper IAM permissions for CloudWatch and S3 access

### Monitoring

- Monitor WAF metrics in CloudWatch
- Set up alarms for blocked requests and rate limiting
- Review WAF logs regularly for security insights
- Monitor CloudFront and ALB access logs for traffic patterns

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See the LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS WAF documentation
3. Open an issue in the repository

## Changelog

### v1.0.0
- Initial release
- WAF v2 support
- CloudFront integration
- ALB integration
- Comprehensive logging and monitoring
- Custom rules support