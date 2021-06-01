resource "aws_security_group" "this_targets" {
  name        = "${var.alb_name}-targets"
  description = "Security group to allow access to ALB targets from ${var.alb_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.this_alb.id]
    description     = "Allow Any from ALB"
  }

  tags = merge(
    var.input_tags,
    {
      "Name" = "${var.alb_name}-targets"
    },
  )
}
