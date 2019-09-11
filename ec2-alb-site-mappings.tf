
data "aws_acm_certificate" "this" {
  for_each = var.site_mappings

  domain = var.site_mappings[each.key].primary_domain_name
  statuses    = ["ISSUED"]
}

resource "aws_lb_listener_certificate" "this" {
  for_each = var.site_mappings
  
  listener_arn    = aws_lb_listener.this_https.arn
  certificate_arn = data.aws_acm_certificate.this[each.key].arn
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.site_mappings

  listener_arn = "${aws_lb_listener.this_https.arn}"

  action {
    type             = "forward"
    target_group_arn = var.site_mappings[each.key].target_group_arn
  }

  condition {
    field  = "host-header"
    values = flatten([var.site_mappings[each.key].primary_domain_name, var.site_mappings[each.key].alias_domain_names])
  }

  # Syntax that supports multiple values in list after merge of: https://github.com/terraform-providers/terraform-provider-aws/pull/8268
  # More info: https://github.com/terraform-providers/terraform-provider-aws/issues/8126
  # condition {
  #   host_header = flatten([var.site_mappings[each.key].primary_domain_name, var.site_mappings[each.key].alias_domain_names])
  # }
}
