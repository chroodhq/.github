variable "environment" {
  type = string
}

variable "stack_name" {
  type = string
}

variable "domain" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "needs_www_redirect" {
  type    = bool
  default = false
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}

variable "aws_regions" {
  type        = map(string)
  description = "List of AWS regions to deploy resources to"
  default     = {}
}

locals {
  resource_prefix = "${var.stack_name}-${var.environment}"
  common_tags = merge(var.common_tags, {
    managed_by  = "Terraform"
    environment = var.environment
    deployment  = var.stack_name
  })
  aws_regions = merge(var.aws_regions, {
    frankfurt = "eu-central-1"
    ireland   = "eu-west-1"
    virginia  = "us-east-1"
  })

  domain_parts     = split(".", var.domain)
  is_simple_domain = length(local.domain_parts) == 2
  root_domain      = local.is_simple_domain ? var.domain : join(".", slice(local.domain_parts, length(local.domain_parts) - 2, length(local.domain_parts)))
}