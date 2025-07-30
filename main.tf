# AWS WAF + CloudFront/ALB Terraform Module
# This module creates a comprehensive WAF setup with CloudFront distribution and ALB integration

# WAF Web ACL
resource "aws_wafv2_web_acl" "main" {
  name        = var.waf_web_acl_name
  description = var.waf_web_acl_description
  scope       = var.waf_scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  # Rate limiting rule
  dynamic "rule" {
    for_each = var.enable_rate_limiting ? [1] : []
    content {
      name     = "RateLimitRule"
      priority = 1

      override_action {
        none {}
      }

      statement {
        rate_based_statement {
          limit              = var.rate_limit
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "RateLimitRule"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  # AWS managed rules
  dynamic "rule" {
    for_each = var.enable_aws_managed_rules ? [1] : []
    content {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 2

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  # SQL injection rule
  dynamic "rule" {
    for_each = var.enable_sql_injection_protection ? [1] : []
    content {
      name     = "SQLInjectionRule"
      priority = 3

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "SQLInjectionRule"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  # XSS protection rule
  dynamic "rule" {
    for_each = var.enable_xss_protection ? [1] : []
    content {
      name     = "XSSProtectionRule"
      priority = 4

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "XSSProtectionRule"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  # IP reputation list rule
  dynamic "rule" {
    for_each = var.enable_ip_reputation_list ? [1] : []
    content {
      name     = "IPReputationListRule"
      priority = 5

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAnonymousIpList"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "IPReputationListRule"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  # Custom IP block list
  dynamic "rule" {
    for_each = length(var.blocked_ip_addresses) > 0 ? [1] : []
    content {
      name     = "CustomIPBlockList"
      priority = 6

      override_action {
        none {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.blocked_ips[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "CustomIPBlockList"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  # Geo-blocking rule
  dynamic "rule" {
    for_each = length(var.geo_block_countries) > 0 ? [1] : []
    content {
      name     = "GeoBlockingRule"
      priority = 7

      override_action {
        none {}
      }

      statement {
        geo_match_statement {
          country_codes = var.geo_block_countries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "GeoBlockingRule"
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  # Custom rules
  dynamic "rule" {
    for_each = var.custom_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "byte_match_statement" {
          for_each = rule.value.type == "byte_match" ? [rule.value] : []
          content {
            search_string         = byte_match_statement.value.search_string
            positional_constraint = byte_match_statement.value.positional_constraint
            field_to_match {
              dynamic "uri_path" {
                for_each = byte_match_statement.value.field == "uri_path" ? [1] : []
                content {}
              }
              dynamic "query_string" {
                for_each = byte_match_statement.value.field == "query_string" ? [1] : []
                content {}
              }
              dynamic "header" {
                for_each = byte_match_statement.value.field == "header" ? [byte_match_statement.value.header_name] : []
                content {
                  name = header.value
                }
              }
            }
            text_transformation {
              priority = 1
              type     = byte_match_statement.value.text_transformation
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = rule.value.name
        sampled_requests_enabled   = var.enable_sampled_requests
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
    metric_name                = var.waf_web_acl_name
    sampled_requests_enabled   = var.enable_sampled_requests
  }

  tags = var.tags
}

# IP Set for blocked IP addresses
resource "aws_wafv2_ip_set" "blocked_ips" {
  count = length(var.blocked_ip_addresses) > 0 ? 1 : 0

  name               = "${var.waf_web_acl_name}-blocked-ips"
  description        = "IP addresses to block"
  scope              = var.waf_scope
  ip_address_version = "IPV4"
  addresses          = var.blocked_ip_addresses

  tags = var.tags
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  count = var.enable_cloudfront ? 1 : 0

  enabled             = var.cloudfront_enabled
  is_ipv6_enabled     = var.cloudfront_ipv6_enabled
  comment             = var.cloudfront_comment
  default_root_object = var.cloudfront_default_root_object
  price_class         = var.cloudfront_price_class

  # Origin configuration
  dynamic "origin" {
    for_each = var.cloudfront_origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id

      dynamic "s3_origin_config" {
        for_each = origin.value.type == "s3" ? [origin.value] : []
        content {
          origin_access_identity = s3_origin_config.value.origin_access_identity
        }
      }

      dynamic "custom_origin_config" {
        for_each = origin.value.type == "custom" ? [origin.value] : []
        content {
          http_port              = custom_origin_config.value.http_port
          https_port             = custom_origin_config.value.https_port
          origin_protocol_policy = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols   = custom_origin_config.value.origin_ssl_protocols
        }
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_headers != null ? origin.value.custom_headers : []
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods  = var.cloudfront_default_cache_behavior.allowed_methods
    cached_methods   = var.cloudfront_default_cache_behavior.cached_methods
    target_origin_id = var.cloudfront_default_cache_behavior.target_origin_id

    forwarded_values {
      query_string = var.cloudfront_default_cache_behavior.forward_query_string
      headers      = var.cloudfront_default_cache_behavior.forward_headers

      cookies {
        forward = var.cloudfront_default_cache_behavior.forward_cookies
      }
    }

    viewer_protocol_policy = var.cloudfront_default_cache_behavior.viewer_protocol_policy
    min_ttl                = var.cloudfront_default_cache_behavior.min_ttl
    default_ttl            = var.cloudfront_default_cache_behavior.default_ttl
    max_ttl                = var.cloudfront_default_cache_behavior.max_ttl

    dynamic "lambda_function_association" {
      for_each = var.cloudfront_lambda_functions
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lambda_function_association.value.include_body
      }
    }
  }

  # Ordered cache behaviors
  dynamic "ordered_cache_behavior" {
    for_each = var.cloudfront_ordered_cache_behaviors
    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = ordered_cache_behavior.value.allowed_methods
      cached_methods   = ordered_cache_behavior.value.cached_methods
      target_origin_id = ordered_cache_behavior.value.target_origin_id

      forwarded_values {
        query_string = ordered_cache_behavior.value.forward_query_string
        headers      = ordered_cache_behavior.value.forward_headers

        cookies {
          forward = ordered_cache_behavior.value.forward_cookies
        }
      }

      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      min_ttl                = ordered_cache_behavior.value.min_ttl
      default_ttl            = ordered_cache_behavior.value.default_ttl
      max_ttl                = ordered_cache_behavior.value.max_ttl
    }
  }

  # WAF Web ACL association
  dynamic "web_acl_id" {
    for_each = var.associate_waf_with_cloudfront ? [aws_wafv2_web_acl.main.arn] : []
    content {
      web_acl_id = web_acl_id.value
    }
  }

  # Viewer certificate
  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_use_default_certificate
    acm_certificate_arn           = var.cloudfront_acm_certificate_arn
    ssl_support_method            = var.cloudfront_ssl_support_method
    minimum_protocol_version      = var.cloudfront_minimum_protocol_version
  }

  # Custom error responses
  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  # Aliases
  aliases = var.cloudfront_aliases

  # Restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_geo_restriction_type
      locations        = var.cloudfront_geo_restriction_locations
    }
  }

  tags = var.tags
}

# Application Load Balancer
resource "aws_lb" "main" {
  count = var.enable_alb ? 1 : 0

  name               = var.alb_name
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = var.alb_security_groups
  subnets            = var.alb_subnets

  enable_deletion_protection = var.alb_enable_deletion_protection
  enable_http2               = var.alb_enable_http2

  dynamic "access_logs" {
    for_each = var.alb_access_logs_bucket != null ? [1] : []
    content {
      bucket  = var.alb_access_logs_bucket
      prefix  = var.alb_access_logs_prefix
      enabled = true
    }
  }

  tags = var.tags
}

# ALB Target Group
resource "aws_lb_target_group" "main" {
  count = var.enable_alb ? 1 : 0

  name     = var.alb_target_group_name
  port     = var.alb_target_group_port
  protocol = var.alb_target_group_protocol
  vpc_id   = var.alb_vpc_id

  dynamic "health_check" {
    for_each = [var.alb_health_check]
    content {
      enabled             = health_check.value.enabled
      healthy_threshold   = health_check.value.healthy_threshold
      interval            = health_check.value.interval
      matcher             = health_check.value.matcher
      path                = health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      timeout             = health_check.value.timeout
      unhealthy_threshold = health_check.value.unhealthy_threshold
    }
  }

  tags = var.tags
}

# ALB Listener
resource "aws_lb_listener" "main" {
  count = var.enable_alb ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol
  ssl_policy        = var.alb_listener_ssl_policy
  certificate_arn   = var.alb_listener_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }

  tags = var.tags
}

# WAF Web ACL Association with ALB
resource "aws_wafv2_web_acl_association" "alb" {
  count = var.enable_alb && var.associate_waf_with_alb ? 1 : 0

  resource_arn = aws_lb.main[0].arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# CloudWatch Log Group for WAF
resource "aws_cloudwatch_log_group" "waf" {
  count = var.enable_waf_logging ? 1 : 0

  name              = "/aws/waf/${var.waf_web_acl_name}"
  retention_in_days = var.waf_log_retention_days

  tags = var.tags
}

# Kinesis Firehose for WAF logs (if enabled)
resource "aws_kinesis_firehose_delivery_stream" "waf_logs" {
  count = var.enable_waf_logging && var.enable_kinesis_firehose ? 1 : 0

  name        = "${var.waf_web_acl_name}-waf-logs"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role[0].arn
    bucket_arn = var.waf_logs_s3_bucket_arn
    prefix     = "waf-logs/"
  }

  tags = var.tags
}

# IAM Role for Kinesis Firehose
resource "aws_iam_role" "firehose_role" {
  count = var.enable_waf_logging && var.enable_kinesis_firehose ? 1 : 0

  name = "${var.waf_web_acl_name}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Kinesis Firehose
resource "aws_iam_role_policy" "firehose_policy" {
  count = var.enable_waf_logging && var.enable_kinesis_firehose ? 1 : 0

  name = "${var.waf_web_acl_name}-firehose-policy"
  role = aws_iam_role.firehose_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          var.waf_logs_s3_bucket_arn,
          "${var.waf_logs_s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

# WAF Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count = var.enable_waf_logging ? 1 : 0

  log_destination_configs = var.enable_kinesis_firehose ? [aws_kinesis_firehose_delivery_stream.waf_logs[0].arn] : [aws_cloudwatch_log_group.waf[0].arn]
  resource_arn            = aws_wafv2_web_acl.main.arn

  dynamic "logging_filter" {
    for_each = var.waf_logging_filters != null ? [var.waf_logging_filters] : []
    content {
      default_behavior = logging_filter.value.default_behavior

      dynamic "filter" {
        for_each = logging_filter.value.filters
        content {
          behavior = filter.value.behavior
          condition {
            action_condition {
              action = filter.value.condition_action
            }
          }
          requirement = filter.value.requirement
        }
      }
    }
  }
} 