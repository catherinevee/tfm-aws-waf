# Contributing to AWS WAF + CloudFront/ALB Terraform Module

Thank you for your interest in contributing to the AWS WAF + CloudFront/ALB Terraform Module! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

- Use the GitHub issue tracker
- Include detailed steps to reproduce the bug
- Provide Terraform configuration examples
- Include error messages and logs
- Specify your Terraform and AWS provider versions

### Suggesting Enhancements

- Use the GitHub issue tracker with the "enhancement" label
- Describe the use case and benefits
- Provide examples of how the enhancement would be used
- Consider backward compatibility

### Submitting Code Changes

- Fork the repository
- Create a feature branch from `main`
- Make your changes following the coding standards
- Add tests for new functionality
- Update documentation
- Submit a pull request

## Development Setup

### Prerequisites

- Terraform >= 1.13.0
- AWS CLI configured
- Go (for running tests)
- Make (for using the Makefile)

### Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/tfm-aws-waf.git
   cd tfm-aws-waf
   ```

2. Initialize Terraform:
   ```bash
   make init
   ```

3. Run tests:
   ```bash
   make test
   ```

4. Validate code:
   ```bash
   make validate
   make fmt
   make lint
   ```

## Coding Standards

### Terraform Code Style

- Use consistent indentation (2 spaces)
- Use descriptive variable and resource names
- Follow HashiCorp's Terraform style guide
- Use `terraform fmt` to format code

### Variable Definitions

- Provide comprehensive descriptions
- Use appropriate types and validation
- Mark sensitive variables with `sensitive = true`
- Use meaningful default values

Example:
```hcl
variable "waf_web_acl_name" {
  description = "Name of the WAF Web ACL. Must be unique within the scope and region."
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.waf_web_acl_name))
    error_message = "WAF Web ACL name must contain only alphanumeric characters, hyphens, and underscores."
  }
}
```

### Resource Definitions

- Use consistent naming conventions
- Add appropriate tags to all resources
- Use data sources when appropriate
- Implement proper error handling

### Output Definitions

- Provide clear descriptions
- Use consistent naming patterns
- Include dependency information when relevant

## Testing Guidelines

### Test Requirements

- All new features must include tests
- Tests should cover both positive and negative cases
- Use Terraform's native testing framework (`.tftest.hcl`)
- Include integration tests for complex scenarios

### Test Structure

```hcl
# tests/feature_name.tftest.hcl
run "feature_name_test" {
  command = plan
  
  variables {
    # Test-specific variables
  }
  
  assert {
    condition     = resource.attribute == expected_value
    error_message = "Clear error message"
  }
}
```

### Running Tests

```bash
# Run all tests
terraform test

# Run specific test file
terraform test tests/basic.tftest.hcl

# Run with verbose output
terraform test -verbose
```

## Documentation Standards

### README Updates

- Update README.md for new features
- Include usage examples
- Update variable and output tables
- Add architecture diagrams when relevant

### Code Comments

- Comment complex logic
- Explain business rules
- Document workarounds
- Use clear, concise language

### Example Updates

- Update examples for new features
- Ensure examples are working
- Include realistic configurations
- Add comments explaining choices

## Pull Request Process

### Before Submitting

1. Ensure all tests pass
2. Run code validation:
   ```bash
   make validate
   make fmt
   make lint
   ```
3. Update documentation
4. Test with different configurations

### Pull Request Guidelines

- Use descriptive titles
- Include issue references
- Provide detailed descriptions
- Include testing instructions
- Add screenshots for UI changes

### Review Process

- All PRs require at least one review
- Address review comments promptly
- Maintain clean commit history
- Squash commits when appropriate

## Release Process

### Version Management

- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update CHANGELOG.md for all releases
- Tag releases in Git
- Update version constraints in examples

### Release Checklist

- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped
- [ ] Git tag created
- [ ] Release notes written

### Breaking Changes

- Document breaking changes clearly
- Provide migration guides
- Maintain backward compatibility when possible
- Use major version bumps for breaking changes

## Getting Help

- Check existing issues and documentation
- Ask questions in GitHub discussions
- Join our community channels
- Review the troubleshooting guide

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project (MIT License).

## Acknowledgments

Thank you to all contributors who have helped make this module better! 