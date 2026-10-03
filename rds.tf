resource "aws_db_subnet_group" "metabase" {
  name       = "lab-metabase-db-subnets"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "lab-metabase-db-subnets"
  }
}

resource "aws_db_instance" "metabase" {
  identifier = "lab-metabase-db"

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  engine         = "postgres"
  engine_version = "17"
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.metabase.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true

  apply_immediately = true

  tags = {
    Name = "lab-metabase-db"
  }
}
