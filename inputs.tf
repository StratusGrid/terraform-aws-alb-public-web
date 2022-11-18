variable "alb_name" {
  description = "Unique string name of ALB to be created. Also prepends supporting resource names"
  type        = string
}

variable "site_mappings" {
  description = "A map of maps for each site active on the ALB. Maximum of 25 site mappings per ALB!."
  type = map(object(
    {
      primary_domain_name = string
      alias_domain_names  = list(string)
      target_group_arn    = string
    }
  ))
  default = {}
}

variable "site_mappings_auth" {
  description = "A map of maps for each site active on the ALB which has authentication via cognito. Maximum of 25 site mappings per ALB!."
  type = map(object(
    {
      primary_domain_name      = string
      alias_domain_names       = list(string)
      target_group_arn         = string
      cognito_user_pool_arn    = string
      cognito_user_pool_domain = string
    }
  ))
  default = {}
}

variable "input_tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default = {
    Developer   = "GenesisFunction"
    Provisioner = "Terraform"
  }
}

variable "default_acm_certificate_arn" {
  description = "Certificate that is used for default https action"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC which the resource should be created in"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of Subnets which the alb should be attached to"
  type        = list(string)
  default     = []
}

variable "enable_deletion_protection" {
  description = "whether or not to enable deletion protection on the ALB. Defaults to true"
  type        = bool
  default     = true
}

variable "log_bucket_id" {
  description = "ID of logging bucket to be targeted alb logs"
  type        = string
}

variable "log_prefix" {
  description = "common prefix to place logs into. elb would become elb/alb_name/LOGS"
  type        = string
  default     = "elb"
}

variable "internal_only" {
  description = "true/false of whether load balancer should be internal only (no elastic IPs). Default is false"
  type        = bool
  default     = false
}

variable "security_policy" {
  description = "ALB Security Policy - determines supported TLS versions and ciphers for ALL SITES. Default is TLS 1.2 only"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

