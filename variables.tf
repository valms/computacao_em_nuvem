variable "aws_region" {
  description = "AWS region for all lab resources."
  type        = string
  default     = "us-east-1"
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR notation for SSH access, for example 203.0.113.10/32."
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0))
    error_message = "my_ip_cidr must be a valid CIDR block, for example 203.0.113.10/32."
  }
}

variable "ssh_public_key" {
  description = "Public SSH key used to create the EC2 key pair. Use ~/.ssh/lab-metabase-key.pub."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password for the postgres user."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "db_password must be at least 8 characters."
  }
}

variable "leitura_password" {
  description = "Password for the read-only metabase_leitura PostgreSQL user in the loja database."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.leitura_password) >= 8
    error_message = "leitura_password must be at least 8 characters."
  }
}

variable "db_username" {
  description = "RDS master username."
  type        = string
  default     = "postgres"
}

variable "db_name" {
  description = "Initial PostgreSQL database used by Metabase for internal state."
  type        = string
  default     = "metabase"
}

variable "instance_type" {
  description = "EC2 instance type for Metabase."
  type        = string
  default     = "t4g.small"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "metabase_image" {
  description = "Metabase Docker image tag from the lab PDF."
  type        = string
  default     = "metabase/metabase:v0.63.19.1"
}

variable "default_tags" {
  description = "Tags applied to all supported AWS resources."
  type        = map(string)
  default = {
    turma      = "turma3"
    disciplina = "computacao em nuvem"
    projeto    = "metabase-rds-alb"
    ambiente   = "lab"
  }
}
