# create application load balancer
resource "aws_lb" "application_load_balancer" {

  name                       = "${var.project_name}-elb"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = [var.public_subnet_az1_id, var.public_subnet_az2_id]
  security_groups            = [var.alb_security_group]
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-elb"
  }
}

# create listener
resource "aws_lb_listener" "application_load_balancer_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# create target group
resource "aws_lb_target_group" "alb_target_group" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

# create load balancer target group attachment
resource "aws_lb_target_group_attachment" "my-aws-alb" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = var.instance_1
  port             = 80
}

# create load balancer target group attachment
resource "aws_lb_target_group_attachment" "my-aws-alb2" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = var.instance_2
  port             = 80
}