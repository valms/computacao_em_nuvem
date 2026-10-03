data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

data "aws_ssm_parameter" "amazon_linux_2023_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

locals {
  default_subnets_by_az = {
    for subnet in data.aws_subnet.default : subnet.availability_zone => subnet.id
  }

  selected_subnet_ids = slice(sort(values(local.default_subnets_by_az)), 0, 2)
  ec2_subnet_id       = local.selected_subnet_ids[0]
}
