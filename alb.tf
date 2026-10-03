resource "aws_lb" "metabase" {
  name               = "alb-metabase"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.selected_subnet_ids

  tags = {
    Name = "alb-metabase"
  }
}

resource "aws_lb_target_group" "metabase" {
  name        = "tg-metabase"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    enabled             = true
    path                = "/api/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
  }

  tags = {
    Name = "tg-metabase"
  }
}

resource "aws_lb_target_group_attachment" "metabase" {
  target_group_arn = aws_lb_target_group.metabase.arn
  target_id        = aws_instance.metabase.id
  port             = 3000
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.metabase.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metabase.arn
  }

  tags = {
    Name = "alb-metabase-http"
  }
}
