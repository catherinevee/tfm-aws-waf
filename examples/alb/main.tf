# ALB WAF Example
# This example demonstrates WAF configuration with Application Load Balancer

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# VPC for ALB
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "waf-alb-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "waf-alb-igw"
  }
}

# Public subnets for ALB
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "waf-alb-public-subnet-${count.index + 1}"
  }
}

# Private subnets for EC2 instances
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "waf-alb-private-subnet-${count.index + 1}"
  }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "waf-alb-public-rt"
  }
}

# Route table association for public subnets
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security group for ALB
resource "aws_security_group" "alb" {
  name        = "waf-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "waf-alb-sg"
  }
}

# Security group for EC2 instances
resource "aws_security_group" "ec2" {
  name        = "waf-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "waf-ec2-sg"
  }
}

# ACM Certificate for ALB
resource "aws_acm_certificate" "alb" {
  domain_name       = "example.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 hosted zone
resource "aws_route53_zone" "main" {
  name = "example.com"
}

# DNS validation records
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# EC2 instances (example backend)
resource "aws_instance" "web" {
  count         = 2
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private[count.index].id

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from EC2 instance $(hostname -f)</h1>" > /var/www/html/index.html
              echo "<h2>Health check endpoint</h2>" > /var/www/html/health.html
              EOF

  tags = {
    Name = "waf-web-instance-${count.index + 1}"
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "waf_alb" {
  source = "../../"

  # WAF Configuration for ALB
  waf_web_acl_name        = "alb-waf-example"
  waf_web_acl_description = "WAF configuration for ALB"
  waf_scope               = "REGIONAL"
  default_action          = "allow"

  # Enable security features
  enable_rate_limiting        = true
  rate_limit                  = 1500
  enable_aws_managed_rules    = true
  enable_sql_injection_protection = true
  enable_xss_protection       = true
  enable_ip_reputation_list   = true

  # Block specific IP addresses
  blocked_ip_addresses = [
    "192.168.1.100/32",
    "10.0.0.0/8"
  ]

  # Geo-blocking
  geo_block_countries = [
    "CN",  # China
    "RU",  # Russia
    "KP"   # North Korea
  ]

  # Custom rules for ALB
  custom_rules = [
    {
      name     = "BlockAdminAccess"
      priority = 10
      action   = "block"
      type     = "byte_match"
      search_string = "/admin"
      positional_constraint = "STARTS_WITH"
      field    = "uri_path"
      text_transformation = "LOWERCASE"
    },
    {
      name     = "BlockSuspiciousUserAgents"
      priority = 11
      action   = "block"
      type     = "byte_match"
      search_string = "scanner"
      positional_constraint = "CONTAINS"
      field    = "header"
      header_name = "User-Agent"
      text_transformation = "LOWERCASE"
    },
    {
      name     = "BlockSQLInjectionAttempts"
      priority = 12
      action   = "block"
      type     = "byte_match"
      search_string = "union select"
      positional_constraint = "CONTAINS"
      field    = "query_string"
      text_transformation = "LOWERCASE"
    }
  ]

  # ALB Configuration
  enable_alb = true
  associate_waf_with_alb = true

  alb_name = "waf-alb-example"
  alb_internal = false
  alb_subnets = aws_subnet.public[*].id
  alb_security_groups = [aws_security_group.alb.id]
  alb_vpc_id = aws_vpc.main.id

  alb_enable_deletion_protection = false
  alb_enable_http2 = true

  # ALB Target Group
  alb_target_group_name = "waf-alb-tg"
  alb_target_group_port = 80
  alb_target_group_protocol = "HTTP"

  # Health Check
  alb_health_check = {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health.html"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  # ALB Listener
  alb_listener_port = 443
  alb_listener_protocol = "HTTPS"
  alb_listener_ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  alb_listener_certificate_arn = aws_acm_certificate.alb.arn

  # Monitoring and logging
  enable_cloudwatch_metrics = true
  enable_sampled_requests   = true
  enable_waf_logging        = true
  waf_log_retention_days    = 60

  # Tags
  tags = {
    Environment = "production"
    Project     = "alb-waf"
    Owner       = "devops-team"
    CostCenter  = "security"
  }
}

# Target group attachment
resource "aws_lb_target_group_attachment" "web" {
  count            = 2
  target_group_arn = module.waf_alb.alb_target_group_arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# Route53 A record for ALB
resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "alb.example.com"
  type    = "A"

  alias {
    name                   = module.waf_alb.alb_dns_name
    zone_id                = module.waf_alb.alb_zone_id
    evaluate_target_health = true
  }
} 