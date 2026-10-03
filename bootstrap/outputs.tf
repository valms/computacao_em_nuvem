output "backend_config" {
  description = "Copy these values into ../backend.hcl."
  value = {
    bucket       = aws_s3_bucket.terraform_state.id
    key          = "computacao-em-nuvem/metabase-lab/terraform.tfstate"
    region       = var.aws_region
    encrypt      = true
    use_lockfile = true
  }
}

output "s3_bucket_name" {
  description = "S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.id
}
