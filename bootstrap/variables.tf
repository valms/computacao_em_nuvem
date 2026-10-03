variable "aws_region" {
  description = "AWS region for the Terraform state bucket."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Unique S3 bucket name for Terraform remote state. Leave null to generate one."
  type        = string
  default     = null
}

variable "default_tags" {
  description = "Tags applied to bootstrap resources."
  type        = map(string)
  default = {
    turma      = "turma3"
    disciplina = "computacao em nuvem"
    projeto    = "metabase-rds-alb"
    ambiente   = "lab"
  }
}
