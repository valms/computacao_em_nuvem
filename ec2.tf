resource "aws_key_pair" "metabase" {
  key_name   = "lab-metabase-key"
  public_key = var.ssh_public_key

  tags = {
    Name = "lab-metabase-key"
  }
}

locals {
  docker_compose = templatefile("${path.module}/templates/docker-compose.yml.tftpl", {
    metabase_image = var.metabase_image
  })
  seed_sql = file("${path.module}/docs/files/seed-loja.sql")
}

resource "aws_instance" "metabase" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023_arm64.value
  instance_type               = var.instance_type
  subnet_id                   = local.ec2_subnet_id
  vpc_security_group_ids      = [aws_security_group.metabase.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.metabase.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    db_host          = aws_db_instance.metabase.address
    db_name          = var.db_name
    db_user          = var.db_username
    db_password      = var.db_password
    leitura_password = var.leitura_password
    site_url         = "http://${aws_lb.metabase.dns_name}"
    docker_compose   = local.docker_compose
    seed_sql         = local.seed_sql
  })

  depends_on = [aws_db_instance.metabase]

  tags = {
    Name = "ec2-metabase"
  }
}
