resource "aws_lb" "alb" {
  name               = "simple-timeservice-alb"
  load_balancer_type = "application"
  subnets            = local.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]
  idle_timeout       = 60
  enable_deletion_protection = false
  tags = { Name = "simple-timeservice-alb" }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}