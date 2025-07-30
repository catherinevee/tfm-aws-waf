# Makefile for AWS WAF + CloudFront/ALB Terraform Module

.PHONY: help init plan apply destroy validate fmt lint test clean

# Default target
help:
	@echo "Available commands:"
	@echo "  init      - Initialize Terraform"
	@echo "  plan      - Plan Terraform changes"
	@echo "  apply     - Apply Terraform changes"
	@echo "  destroy   - Destroy Terraform resources"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  fmt       - Format Terraform code"
	@echo "  lint      - Lint Terraform code"
	@echo "  test      - Run tests"
	@echo "  clean     - Clean up temporary files"
	@echo "  docs      - Generate documentation"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Plan Terraform changes
plan:
	@echo "Planning Terraform changes..."
	terraform plan

# Apply Terraform changes
apply:
	@echo "Applying Terraform changes..."
	terraform apply -auto-approve

# Destroy Terraform resources
destroy:
	@echo "Destroying Terraform resources..."
	terraform destroy -auto-approve

# Validate Terraform configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate

# Format Terraform code
fmt:
	@echo "Formatting Terraform code..."
	terraform fmt -recursive

# Lint Terraform code (requires tflint)
lint:
	@echo "Linting Terraform code..."
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --init; \
		tflint; \
	else \
		echo "tflint not found. Install it from https://github.com/terraform-linters/tflint"; \
		exit 1; \
	fi

# Run tests (requires terratest)
test:
	@echo "Running tests..."
	@if command -v go >/dev/null 2>&1; then \
		cd test && go test -v -timeout 30m; \
	else \
		echo "Go not found. Install it to run tests."; \
		exit 1; \
	fi

# Clean up temporary files
clean:
	@echo "Cleaning up temporary files..."
	rm -rf .terraform
	rm -rf .terraform.lock.hcl
	rm -f terraform.tfstate
	rm -f terraform.tfstate.backup
	rm -rf .tflint.d

# Generate documentation
docs:
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table . > README.md.tmp; \
		mv README.md.tmp README.md; \
	else \
		echo "terraform-docs not found. Install it from https://github.com/terraform-docs/terraform-docs"; \
		exit 1; \
	fi

# Security scan (requires terrascan)
security-scan:
	@echo "Running security scan..."
	@if command -v terrascan >/dev/null 2>&1; then \
		terrascan scan -i terraform; \
	else \
		echo "terrascan not found. Install it from https://github.com/tenable/terrascan"; \
		exit 1; \
	fi

# Cost estimation (requires infracost)
cost-estimate:
	@echo "Estimating costs..."
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path .; \
	else \
		echo "infracost not found. Install it from https://github.com/infracost/infracost"; \
		exit 1; \
	fi

# Check for updates
check-updates:
	@echo "Checking for provider updates..."
	terraform init -upgrade

# Workspace management
workspace-dev:
	@echo "Switching to development workspace..."
	terraform workspace select dev || terraform workspace new dev

workspace-staging:
	@echo "Switching to staging workspace..."
	terraform workspace select staging || terraform workspace new staging

workspace-prod:
	@echo "Switching to production workspace..."
	terraform workspace select prod || terraform workspace new prod

# Example deployments
deploy-basic:
	@echo "Deploying basic example..."
	cd examples/basic && terraform init && terraform apply -auto-approve

deploy-cloudfront:
	@echo "Deploying CloudFront example..."
	cd examples/cloudfront && terraform init && terraform apply -auto-approve

deploy-alb:
	@echo "Deploying ALB example..."
	cd examples/alb && terraform init && terraform apply -auto-approve

# Clean up examples
clean-examples:
	@echo "Cleaning up examples..."
	cd examples/basic && terraform destroy -auto-approve || true
	cd examples/cloudfront && terraform destroy -auto-approve || true
	cd examples/alb && terraform destroy -auto-approve || true

# Pre-commit checks
pre-commit: fmt validate lint
	@echo "Pre-commit checks completed successfully!"

# CI/CD pipeline
ci: init validate fmt lint test
	@echo "CI pipeline completed successfully!"

# Development setup
dev-setup:
	@echo "Setting up development environment..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install terraform tflint terrascan infracost terraform-docs; \
	elif command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y terraform; \
		echo "Please install tflint, terrascan, infracost, and terraform-docs manually"; \
	else \
		echo "Please install required tools manually"; \
	fi 