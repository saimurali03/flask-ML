variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "ecr_repo_url" {
  type    = string
  description = "ECR repo URL passed from Jenkins"
}

variable "image_tag" {
  type    = string
  description = "Docker image tag"
  default = "latest"
}
