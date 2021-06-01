resource "aws_lb" "this" {
  name = var.alb_name
  internal = var.internal_only
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.this_alb.id]

  subnets = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket = var.log_bucket_id
    prefix = "${var.log_prefix}/${var.alb_name}"
    enabled = true
  }

  tags = local.common_tags
}

resource "aws_lb_listener" "this_http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "this_https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.security_policy
  certificate_arn   = var.default_acm_certificate_arn

  default_action {
    type             = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Invalid Host Header"
      status_code  = "400"
    }
  }
}
