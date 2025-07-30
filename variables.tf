# AWS WAF + CloudFront/ALB Module Variables

# WAF Configuration
variable "waf_web_acl_name" {
  description = "Name of the WAF Web ACL"
  type        = string
  default     = "waf-web-acl"

  validation {
    condition     = length(var.waf_web_acl_name) >= 1 && length(var.waf_web_acl_name) <= 128
    error_message = "WAF Web ACL name must be between 1 and 128 characters."
  }
}

variable "waf_web_acl_description" {
  description = "Description of the WAF Web ACL"
  type        = string
  default     = "WAF Web ACL for protecting web applications"
}

variable "waf_scope" {
  description = "Scope of the WAF Web ACL (REGIONAL or CLOUDFRONT)"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.waf_scope)
    error_message = "WAF scope must be either REGIONAL or CLOUDFRONT."
  }
}

variable "default_action" {
  description = "Default action for the WAF Web ACL (allow or block)"
  type        = string
  default     = "allow"

  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Default action must be either 'allow' or 'block'."
  }
}

# WAF Rules Configuration
variable "enable_rate_limiting" {
  description = "Enable rate limiting rule"
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Rate limit for requests per 5 minutes"
  type        = number
  default     = 2000

  validation {
    condition     = var.rate_limit >= 100 && var.rate_limit <= 2000000
    error_message = "Rate limit must be between 100 and 2,000,000."
  }
}

variable "enable_aws_managed_rules" {
  description = "Enable AWS managed rules"
  type        = bool
  default     = true
}

variable "enable_sql_injection_protection" {
  description = "Enable SQL injection protection"
  type        = bool
  default     = true
}

variable "enable_xss_protection" {
  description = "Enable XSS protection"
  type        = bool
  default     = true
}

variable "enable_ip_reputation_list" {
  description = "Enable IP reputation list protection"
  type        = bool
  default     = true
}

variable "blocked_ip_addresses" {
  description = "List of IP addresses to block"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for ip in var.blocked_ip_addresses : can(cidrhost(ip, 0))
    ])
    error_message = "All blocked IP addresses must be valid CIDR blocks."
  }
}

variable "geo_block_countries" {
  description = "List of country codes to block"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for country in var.geo_block_countries : length(country) == 2
    ])
    error_message = "Country codes must be 2-letter ISO codes."
  }
}

variable "custom_rules" {
  description = "List of custom WAF rules"
  type = list(object({
    name                    = string
    priority                = number
    action                  = string
    type                    = string
    search_string          = optional(string)
    positional_constraint  = optional(string)
    field                   = optional(string)
    header_name            = optional(string)
    text_transformation    = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.custom_rules : contains(["allow", "block"], rule.action)
    ])
    error_message = "Custom rule action must be either 'allow' or 'block'."
  }
}

# WAF Monitoring and Logging
variable "enable_cloudwatch_metrics" {
  description = "Enable CloudWatch metrics for WAF rules"
  type        = bool
  default     = true
}

variable "enable_sampled_requests" {
  description = "Enable sampled requests for WAF rules"
  type        = bool
  default     = true
}

variable "enable_waf_logging" {
  description = "Enable WAF logging"
  type        = bool
  default     = true
}

variable "waf_log_retention_days" {
  description = "Number of days to retain WAF logs"
  type        = number
  default     = 30

  validation {
    condition     = var.waf_log_retention_days >= 1 && var.waf_log_retention_days <= 3653
    error_message = "Log retention days must be between 1 and 3653."
  }
}

variable "enable_kinesis_firehose" {
  description = "Enable Kinesis Firehose for WAF logs"
  type        = bool
  default     = false
}

variable "waf_logs_s3_bucket_arn" {
  description = "S3 bucket ARN for WAF logs"
  type        = string
  default     = null
}

variable "waf_logging_filters" {
  description = "WAF logging filters configuration"
  type = object({
    default_behavior = string
    filters = list(object({
      behavior         = string
      condition_action = string
      requirement      = string
    }))
  })
  default = null
}

# CloudFront Configuration
variable "enable_cloudfront" {
  description = "Enable CloudFront distribution"
  type        = bool
  default     = false
}

variable "associate_waf_with_cloudfront" {
  description = "Associate WAF with CloudFront distribution"
  type        = bool
  default     = true
}

variable "cloudfront_enabled" {
  description = "Enable CloudFront distribution"
  type        = bool
  default     = true
}

variable "cloudfront_ipv6_enabled" {
  description = "Enable IPv6 for CloudFront"
  type        = bool
  default     = true
}

variable "cloudfront_comment" {
  description = "Comment for CloudFront distribution"
  type        = string
  default     = "CloudFront distribution with WAF protection"
}

variable "cloudfront_default_root_object" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}

variable "cloudfront_price_class" {
  description = "Price class for CloudFront"
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.cloudfront_price_class)
    error_message = "Price class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
}

variable "cloudfront_origins" {
  description = "List of CloudFront origins"
  type = list(object({
    domain_name              = string
    origin_id                = string
    type                     = string
    origin_access_identity   = optional(string)
    http_port                = optional(number)
    https_port               = optional(number)
    origin_protocol_policy   = optional(string)
    origin_ssl_protocols     = optional(list(string))
    custom_headers           = optional(list(object({
      name  = string
      value = string
    })))
  }))
  default = []
}

variable "cloudfront_default_cache_behavior" {
  description = "Default cache behavior for CloudFront"
  type = object({
    allowed_methods          = list(string)
    cached_methods           = list(string)
    target_origin_id         = string
    forward_query_string     = bool
    forward_headers          = list(string)
    forward_cookies          = string
    viewer_protocol_policy   = string
    min_ttl                  = number
    default_ttl              = number
    max_ttl                  = number
  })
  default = {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "default"
    forward_query_string   = false
    forward_headers        = []
    forward_cookies        = "none"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }
}

variable "cloudfront_ordered_cache_behaviors" {
  description = "Ordered cache behaviors for CloudFront"
  type = list(object({
    path_pattern           = string
    allowed_methods        = list(string)
    cached_methods         = list(string)
    target_origin_id       = string
    forward_query_string   = bool
    forward_headers        = list(string)
    forward_cookies        = string
    viewer_protocol_policy = string
    min_ttl                = number
    default_ttl            = number
    max_ttl                = number
  }))
  default = []
}

variable "cloudfront_lambda_functions" {
  description = "Lambda function associations for CloudFront"
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = bool
  }))
  default = []
}

variable "cloudfront_use_default_certificate" {
  description = "Use CloudFront default certificate"
  type        = bool
  default     = true
}

variable "cloudfront_acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront"
  type        = string
  default     = null
}

variable "cloudfront_ssl_support_method" {
  description = "SSL support method for CloudFront"
  type        = string
  default     = "sni-only"

  validation {
    condition     = contains(["sni-only", "vip"], var.cloudfront_ssl_support_method)
    error_message = "SSL support method must be either 'sni-only' or 'vip'."
  }
}

variable "cloudfront_minimum_protocol_version" {
  description = "Minimum protocol version for CloudFront"
  type        = string
  default     = "TLSv1.2_2021"

  validation {
    condition = contains([
      "SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2_2018", "TLSv1.2_2019", "TLSv1.2_2021", "TLSv1.3"
    ], var.cloudfront_minimum_protocol_version)
    error_message = "Invalid minimum protocol version."
  }
}

variable "cloudfront_custom_error_responses" {
  description = "Custom error responses for CloudFront"
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []
}

variable "cloudfront_aliases" {
  description = "Aliases for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "cloudfront_geo_restriction_type" {
  description = "Geo restriction type for CloudFront"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.cloudfront_geo_restriction_type)
    error_message = "Geo restriction type must be 'none', 'whitelist', or 'blacklist'."
  }
}

variable "cloudfront_geo_restriction_locations" {
  description = "Geo restriction locations for CloudFront"
  type        = list(string)
  default     = []
}

# ALB Configuration
variable "enable_alb" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = false
}

variable "associate_waf_with_alb" {
  description = "Associate WAF with ALB"
  type        = bool
  default     = true
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "alb"

  validation {
    condition     = length(var.alb_name) >= 1 && length(var.alb_name) <= 32
    error_message = "ALB name must be between 1 and 32 characters."
  }
}

variable "alb_internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "alb_security_groups" {
  description = "Security groups for the ALB"
  type        = list(string)
  default     = []
}

variable "alb_subnets" {
  description = "Subnets for the ALB"
  type        = list(string)
  default     = []
}

variable "alb_enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "alb_enable_http2" {
  description = "Enable HTTP/2 for ALB"
  type        = bool
  default     = true
}

variable "alb_access_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
  default     = null
}

variable "alb_access_logs_prefix" {
  description = "Prefix for ALB access logs"
  type        = string
  default     = "alb-logs"
}

variable "alb_target_group_name" {
  description = "Name of the ALB target group"
  type        = string
  default     = "alb-target-group"

  validation {
    condition     = length(var.alb_target_group_name) >= 1 && length(var.alb_target_group_name) <= 32
    error_message = "ALB target group name must be between 1 and 32 characters."
  }
}

variable "alb_target_group_port" {
  description = "Port for the ALB target group"
  type        = number
  default     = 80

  validation {
    condition     = var.alb_target_group_port >= 1 && var.alb_target_group_port <= 65535
    error_message = "ALB target group port must be between 1 and 65535."
  }
}

variable "alb_target_group_protocol" {
  description = "Protocol for the ALB target group"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP", "TLS"], var.alb_target_group_protocol)
    error_message = "ALB target group protocol must be HTTP, HTTPS, TCP, or TLS."
  }
}

variable "alb_vpc_id" {
  description = "VPC ID for the ALB target group"
  type        = string
  default     = null
}

variable "alb_health_check" {
  description = "Health check configuration for ALB target group"
  type = object({
    enabled             = bool
    healthy_threshold   = number
    interval            = number
    matcher             = string
    path                = string
    port                = string
    protocol            = string
    timeout             = number
    unhealthy_threshold = number
  })
  default = {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

variable "alb_listener_port" {
  description = "Port for the ALB listener"
  type        = number
  default     = 80

  validation {
    condition     = var.alb_listener_port >= 1 && var.alb_listener_port <= 65535
    error_message = "ALB listener port must be between 1 and 65535."
  }
}

variable "alb_listener_protocol" {
  description = "Protocol for the ALB listener"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.alb_listener_protocol)
    error_message = "ALB listener protocol must be HTTP or HTTPS."
  }
}

variable "alb_listener_ssl_policy" {
  description = "SSL policy for the ALB listener"
  type        = string
  default     = null
}

variable "alb_listener_certificate_arn" {
  description = "Certificate ARN for the ALB listener"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
} 

# ==============================================================================
# Enhanced WAF and Security Configuration Variables
# ==============================================================================

variable "waf_config" {
  description = "WAF configuration"
  type = object({
    enable_waf_web_acl = optional(bool, true)
    enable_waf_rules = optional(bool, true)
    enable_waf_rate_limiting = optional(bool, true)
    enable_waf_managed_rules = optional(bool, true)
    enable_waf_custom_rules = optional(bool, false)
    enable_waf_logging = optional(bool, true)
    enable_waf_monitoring = optional(bool, true)
    enable_waf_metrics = optional(bool, true)
    enable_waf_alerts = optional(bool, true)
    enable_waf_dashboard = optional(bool, true)
    enable_waf_audit = optional(bool, true)
    enable_waf_backup = optional(bool, false)
    enable_waf_disaster_recovery = optional(bool, false)
  })
  default = {}
}

variable "waf_web_acls" {
  description = "Map of WAF Web ACLs to create"
  type = map(object({
    name = string
    description = optional(string, null)
    scope = string
    default_action = object({
      allow = optional(object({}), {})
      block = optional(object({}), {})
    })
    rules = optional(list(object({
      name = string
      priority = number
      override_action = optional(object({
        none = optional(object({}), {})
        count = optional(object({}), {})
      }), {})
      visibility_config = object({
        cloudwatch_metrics_enabled = bool
        metric_name = string
        sampled_requests_enabled = bool
      })
      action = optional(object({
        allow = optional(object({}), {})
        block = optional(object({}), {})
        count = optional(object({}), {})
      }), {})
      statement = object({
        managed_rule_group_statement = optional(object({
          name = string
          vendor_name = string
          excluded_rule = optional(list(object({
            name = string
          })), [])
        }), {})
        rate_based_statement = optional(object({
          limit = number
          aggregate_key_type = optional(string, "IP")
          forwarded_ip_config = optional(object({
            header_name = string
            fallback_behavior = string
          }), {})
        }), {})
        geo_match_statement = optional(object({
          country_codes = list(string)
          forwarded_ip_config = optional(object({
            header_name = string
            fallback_behavior = string
          }), {})
        }), {})
        ip_set_reference_statement = optional(object({
          arn = string
          ip_set_forwarded_ip_config = optional(object({
            header_name = string
            fallback_behavior = string
            position = string
          }), {})
        }), {})
        regex_pattern_set_reference_statement = optional(object({
          arn = string
          field_to_match = object({
            single_header = optional(object({
              name = string
            }), {})
            single_query_argument = optional(object({
              name = string
            }), {})
            all_query_parameters = optional(object({}), {})
            uri_path = optional(object({}), {})
            query_string = optional(object({}), {})
            body = optional(object({
              oversize_handling = optional(string, null)
            }), {})
            method = optional(object({}), {})
          })
          text_transformation = list(object({
            priority = number
            type = string
          }))
        }), {})
        rule_group_reference_statement = optional(object({
          arn = string
          excluded_rule = optional(list(object({
            name = string
          })), [])
        }), {})
        and_statement = optional(object({
          statement = list(object({
            managed_rule_group_statement = optional(object({
              name = string
              vendor_name = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
            rate_based_statement = optional(object({
              limit = number
              aggregate_key_type = optional(string, "IP")
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
                position = string
              }), {})
            }), {})
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                single_header = optional(object({
                  name = string
                }), {})
                single_query_argument = optional(object({
                  name = string
                }), {})
                all_query_parameters = optional(object({}), {})
                uri_path = optional(object({}), {})
                query_string = optional(object({}), {})
                body = optional(object({
                  oversize_handling = optional(string, null)
                }), {})
                method = optional(object({}), {})
              })
              text_transformation = list(object({
                priority = number
                type = string
              }))
            }), {})
            rule_group_reference_statement = optional(object({
              arn = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
          }))
        }), {})
        or_statement = optional(object({
          statement = list(object({
            managed_rule_group_statement = optional(object({
              name = string
              vendor_name = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
            rate_based_statement = optional(object({
              limit = number
              aggregate_key_type = optional(string, "IP")
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
                position = string
              }), {})
            }), {})
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                single_header = optional(object({
                  name = string
                }), {})
                single_query_argument = optional(object({
                  name = string
                }), {})
                all_query_parameters = optional(object({}), {})
                uri_path = optional(object({}), {})
                query_string = optional(object({}), {})
                body = optional(object({
                  oversize_handling = optional(string, null)
                }), {})
                method = optional(object({}), {})
              })
              text_transformation = list(object({
                priority = number
                type = string
              }))
            }), {})
            rule_group_reference_statement = optional(object({
              arn = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
          }))
        }), {})
        not_statement = optional(object({
          statement = object({
            managed_rule_group_statement = optional(object({
              name = string
              vendor_name = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
            rate_based_statement = optional(object({
              limit = number
              aggregate_key_type = optional(string, "IP")
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
                position = string
              }), {})
            }), {})
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                single_header = optional(object({
                  name = string
                }), {})
                single_query_argument = optional(object({
                  name = string
                }), {})
                all_query_parameters = optional(object({}), {})
                uri_path = optional(object({}), {})
                query_string = optional(object({}), {})
                body = optional(object({
                  oversize_handling = optional(string, null)
                }), {})
                method = optional(object({}), {})
              })
              text_transformation = list(object({
                priority = number
                type = string
              }))
            }), {})
            rule_group_reference_statement = optional(object({
              arn = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
          })
        }), {})
      })
    })), [])
    visibility_config = object({
      cloudwatch_metrics_enabled = bool
      metric_name = string
      sampled_requests_enabled = bool
    })
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "waf_ip_sets" {
  description = "Map of WAF IP Sets to create"
  type = map(object({
    name = string
    description = optional(string, null)
    scope = string
    ip_address_version = optional(string, "IPV4")
    addresses = list(string)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "waf_regex_pattern_sets" {
  description = "Map of WAF Regex Pattern Sets to create"
  type = map(object({
    name = string
    description = optional(string, null)
    scope = string
    regular_expression = list(object({
      regex_string = string
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "waf_rule_groups" {
  description = "Map of WAF Rule Groups to create"
  type = map(object({
    name = string
    description = optional(string, null)
    scope = string
    capacity = number
    rules = optional(list(object({
      name = string
      priority = number
      override_action = optional(object({
        none = optional(object({}), {})
        count = optional(object({}), {})
      }), {})
      visibility_config = object({
        cloudwatch_metrics_enabled = bool
        metric_name = string
        sampled_requests_enabled = bool
      })
      action = optional(object({
        allow = optional(object({}), {})
        block = optional(object({}), {})
        count = optional(object({}), {})
      }), {})
      statement = object({
        managed_rule_group_statement = optional(object({
          name = string
          vendor_name = string
          excluded_rule = optional(list(object({
            name = string
          })), [])
        }), {})
        rate_based_statement = optional(object({
          limit = number
          aggregate_key_type = optional(string, "IP")
          forwarded_ip_config = optional(object({
            header_name = string
            fallback_behavior = string
          }), {})
        }), {})
        geo_match_statement = optional(object({
          country_codes = list(string)
          forwarded_ip_config = optional(object({
            header_name = string
            fallback_behavior = string
          }), {})
        }), {})
        ip_set_reference_statement = optional(object({
          arn = string
          ip_set_forwarded_ip_config = optional(object({
            header_name = string
            fallback_behavior = string
            position = string
          }), {})
        }), {})
        regex_pattern_set_reference_statement = optional(object({
          arn = string
          field_to_match = object({
            single_header = optional(object({
              name = string
            }), {})
            single_query_argument = optional(object({
              name = string
            }), {})
            all_query_parameters = optional(object({}), {})
            uri_path = optional(object({}), {})
            query_string = optional(object({}), {})
            body = optional(object({
              oversize_handling = optional(string, null)
            }), {})
            method = optional(object({}), {})
          })
          text_transformation = list(object({
            priority = number
            type = string
          }))
        }), {})
        rule_group_reference_statement = optional(object({
          arn = string
          excluded_rule = optional(list(object({
            name = string
          })), [])
        }), {})
        and_statement = optional(object({
          statement = list(object({
            managed_rule_group_statement = optional(object({
              name = string
              vendor_name = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
            rate_based_statement = optional(object({
              limit = number
              aggregate_key_type = optional(string, "IP")
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
                position = string
              }), {})
            }), {})
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                single_header = optional(object({
                  name = string
                }), {})
                single_query_argument = optional(object({
                  name = string
                }), {})
                all_query_parameters = optional(object({}), {})
                uri_path = optional(object({}), {})
                query_string = optional(object({}), {})
                body = optional(object({
                  oversize_handling = optional(string, null)
                }), {})
                method = optional(object({}), {})
              })
              text_transformation = list(object({
                priority = number
                type = string
              }))
            }), {})
            rule_group_reference_statement = optional(object({
              arn = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
          }))
        }), {})
        or_statement = optional(object({
          statement = list(object({
            managed_rule_group_statement = optional(object({
              name = string
              vendor_name = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
            rate_based_statement = optional(object({
              limit = number
              aggregate_key_type = optional(string, "IP")
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
                position = string
              }), {})
            }), {})
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                single_header = optional(object({
                  name = string
                }), {})
                single_query_argument = optional(object({
                  name = string
                }), {})
                all_query_parameters = optional(object({}), {})
                uri_path = optional(object({}), {})
                query_string = optional(object({}), {})
                body = optional(object({
                  oversize_handling = optional(string, null)
                }), {})
                method = optional(object({}), {})
              })
              text_transformation = list(object({
                priority = number
                type = string
              }))
            }), {})
            rule_group_reference_statement = optional(object({
              arn = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
          }))
        }), {})
        not_statement = optional(object({
          statement = object({
            managed_rule_group_statement = optional(object({
              name = string
              vendor_name = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
            rate_based_statement = optional(object({
              limit = number
              aggregate_key_type = optional(string, "IP")
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), {})
            }), {})
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
                position = string
              }), {})
            }), {})
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                single_header = optional(object({
                  name = string
                }), {})
                single_query_argument = optional(object({
                  name = string
                }), {})
                all_query_parameters = optional(object({}), {})
                uri_path = optional(object({}), {})
                query_string = optional(object({}), {})
                body = optional(object({
                  oversize_handling = optional(string, null)
                }), {})
                method = optional(object({}), {})
              })
              text_transformation = list(object({
                priority = number
                type = string
              }))
            }), {})
            rule_group_reference_statement = optional(object({
              arn = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), {})
          })
        }), {})
      })
    })), [])
    visibility_config = object({
      cloudwatch_metrics_enabled = bool
      metric_name = string
      sampled_requests_enabled = bool
    })
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "waf_logging_config" {
  description = "WAF logging configuration"
  type = object({
    enable_waf_logging = optional(bool, true)
    enable_cloudwatch_logs = optional(bool, true)
    enable_kinesis_firehose = optional(bool, false)
    enable_s3_logs = optional(bool, false)
    log_retention_days = optional(number, 30)
    log_group_name = optional(string, null)
    kinesis_firehose_arn = optional(string, null)
    s3_bucket_arn = optional(string, null)
    s3_bucket_prefix = optional(string, null)
    redacted_fields = optional(list(object({
      single_header = optional(object({
        name = string
      }), {})
      single_query_argument = optional(object({
        name = string
      }), {})
      all_query_parameters = optional(object({}), {})
      uri_path = optional(object({}), {})
      query_string = optional(object({}), {})
      body = optional(object({
        oversize_handling = optional(string, null)
      }), {})
      method = optional(object({}), {})
    })), [])
    tags = optional(map(string), {})
  })
  default = {}
}

variable "waf_monitoring_config" {
  description = "WAF monitoring configuration"
  type = object({
    enable_cloudwatch_monitoring = optional(bool, true)
    enable_cloudwatch_logs = optional(bool, true)
    enable_cloudwatch_metrics = optional(bool, true)
    enable_cloudwatch_alarms = optional(bool, true)
    enable_cloudwatch_dashboard = optional(bool, true)
    enable_cloudwatch_insights = optional(bool, false)
    enable_cloudwatch_anomaly_detection = optional(bool, false)
    enable_cloudwatch_rum = optional(bool, false)
    enable_cloudwatch_evidently = optional(bool, false)
    enable_cloudwatch_application_signals = optional(bool, false)
    enable_cloudwatch_synthetics = optional(bool, false)
    enable_cloudwatch_contributor_insights = optional(bool, false)
    enable_cloudwatch_metric_streams = optional(bool, false)
    enable_cloudwatch_metric_filters = optional(bool, false)
    enable_cloudwatch_log_groups = optional(bool, true)
    enable_cloudwatch_log_streams = optional(bool, true)
    enable_cloudwatch_log_subscriptions = optional(bool, false)
    enable_cloudwatch_log_insights = optional(bool, false)
    enable_cloudwatch_log_metric_filters = optional(bool, false)
    enable_cloudwatch_log_destinations = optional(bool, false)
    enable_cloudwatch_log_queries = optional(bool, false)
    enable_cloudwatch_log_analytics = optional(bool, false)
    enable_cloudwatch_log_visualization = optional(bool, false)
    enable_cloudwatch_log_reporting = optional(bool, false)
    enable_cloudwatch_log_archiving = optional(bool, false)
    enable_cloudwatch_log_backup = optional(bool, false)
    enable_cloudwatch_log_retention = optional(bool, true)
    enable_cloudwatch_log_encryption = optional(bool, true)
    enable_cloudwatch_log_access_logging = optional(bool, false)
    enable_cloudwatch_log_audit_logging = optional(bool, false)
    enable_cloudwatch_log_compliance_logging = optional(bool, false)
    enable_cloudwatch_log_security_logging = optional(bool, false)
    enable_cloudwatch_log_performance_logging = optional(bool, true)
    enable_cloudwatch_log_business_logging = optional(bool, false)
    enable_cloudwatch_log_operational_logging = optional(bool, true)
    enable_cloudwatch_log_debug_logging = optional(bool, false)
    enable_cloudwatch_log_trace_logging = optional(bool, false)
    enable_cloudwatch_log_error_logging = optional(bool, true)
    enable_cloudwatch_log_warning_logging = optional(bool, true)
    enable_cloudwatch_log_info_logging = optional(bool, true)
    enable_cloudwatch_log_debug_logging = optional(bool, false)
    enable_cloudwatch_log_verbose_logging = optional(bool, false)
    enable_cloudwatch_log_silent_logging = optional(bool, false)
  })
  default = {}
}

variable "waf_security_config" {
  description = "WAF security configuration"
  type = object({
    enable_waf_encryption = optional(bool, true)
    enable_waf_access_control = optional(bool, true)
    enable_waf_audit_logging = optional(bool, true)
    enable_waf_compliance = optional(bool, false)
    enable_waf_governance = optional(bool, false)
    enable_waf_privacy = optional(bool, false)
    enable_waf_fairness = optional(bool, false)
    enable_waf_bias_detection = optional(bool, false)
    enable_waf_explainability = optional(bool, false)
    enable_waf_interpretability = optional(bool, false)
    enable_waf_robustness = optional(bool, false)
    enable_waf_adversarial_protection = optional(bool, false)
    enable_waf_poisoning_protection = optional(bool, false)
    enable_waf_extraction_protection = optional(bool, false)
    enable_waf_inversion_protection = optional(bool, false)
    enable_waf_membership_inference_protection = optional(bool, false)
    enable_waf_model_inversion_protection = optional(bool, false)
    enable_waf_attribute_inference_protection = optional(bool, false)
    enable_waf_property_inference_protection = optional(bool, false)
    enable_waf_reconstruction_protection = optional(bool, false)
    enable_waf_extraction_protection = optional(bool, false)
    enable_waf_stealing_protection = optional(bool, false)
    enable_waf_evasion_protection = optional(bool, false)
    enable_waf_poisoning_protection = optional(bool, false)
    enable_waf_backdoor_protection = optional(bool, false)
    enable_waf_trojan_protection = optional(bool, false)
    enable_waf_trigger_protection = optional(bool, false)
  })
  default = {}
} 