output "sg_alb_targets_id" {
  description = "ID of security group which ALB targets are added to for ALB to have access"
  value       = aws_security_group.this_targets.id
}

output "alb_dns_name" {
  description = "DNS Name of ALB"
  value       = aws_lb.this.dns_name
}
