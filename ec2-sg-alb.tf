resource "aws_security_group" "this_alb" {
  name        = var.alb_name
  description = "Security group to allow access to ${var.alb_name}"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      "Name" = var.alb_name
    },
  )
}

resource "aws_security_group_rule" "this_alb_egress_to_targets" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  description              = "Allow internet to alb"
  source_security_group_id = aws_security_group.this_targets.id

  security_group_id = aws_security_group.this_alb.id
}

#Needed for Cognito
resource "aws_security_group_rule" "this_alb_egress_to_internet_https" {
  type      = "egress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  #tfsec:ignore:aws-ec2-no-public-egress-sgr
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow alb to internet https"

  security_group_id = aws_security_group.this_alb.id
}

resource "aws_security_group_rule" "this_alb_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  #tfsec:ignore:aws-ec2-no-public-ingress-sgr
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow internet to alb"

  security_group_id = aws_security_group.this_alb.id
}

resource "aws_security_group_rule" "this_alb_https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  #tfsec:ignore:aws-ec2-no-public-ingress-sgr
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow internet to alb"

  security_group_id = aws_security_group.this_alb.id
}
