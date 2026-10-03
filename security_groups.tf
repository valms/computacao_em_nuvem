resource "aws_security_group" "alb" {
  name        = "lab-metabase-alb"
  description = "ALB do Metabase - HTTP publico"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "sg-alb"
  }
}

resource "aws_security_group" "metabase" {
  name        = "lab-metabase-ec2"
  description = "EC2 Metabase"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "sg-metabase"
  }
}

resource "aws_security_group" "rds" {
  name        = "lab-metabase-rds"
  description = "RDS PostgreSQL do lab"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "sg-rds"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP publico para o ALB"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "metabase_from_alb" {
  security_group_id            = aws_security_group.metabase.id
  description                  = "Metabase vindo apenas do ALB"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
}

resource "aws_vpc_security_group_ingress_rule" "metabase_ssh" {
  security_group_id = aws_security_group.metabase.id
  description       = "SSH vindo apenas do IP do aluno"
  cidr_ipv4         = var.my_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_metabase" {
  security_group_id            = aws_security_group.rds.id
  description                  = "PostgreSQL vindo apenas da EC2 Metabase"
  referenced_security_group_id = aws_security_group.metabase.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "metabase_all" {
  security_group_id = aws_security_group.metabase.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
