# Terraform variables placeholder
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "ecr_repo_url" {
  description = "ECR repository full URL (accountid.dkr.ecr.region.amazonaws.com/name)"
  type        = string
}

variable "image_tag" {
  description = "Image tag to deploy"
  type        = string
  default     = "latest"
}

variable "subnets" {
  description = "List of subnet IDs for ECS tasks (must be private/public depending on networking)"
  type        = list(string)
  default     = []
}

variable "security_group" {
  description = "Security group id to attach to the ECS service"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
  default     = ""
}
