variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "ecr_repo_url" {
  type    = string
  default = ""
}

variable "image_tag" {
  type    = string
  default = "latest"
}
