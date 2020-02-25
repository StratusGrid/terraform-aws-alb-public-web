
resource "aws_cognito_user_pool_client" "this_auth" {
  for_each = var.site_mappings_auth

  name = var.site_mappings_auth[each.key].primary_domain_name
  user_pool_id = replace(var.site_mappings_auth[each.key].cognito_user_pool_arn, "/.*(userpool/)(.*$)/", "$${2}")

  generate_secret      = true
  explicit_auth_flows  = ["ADMIN_NO_SRP_AUTH"]
  callback_urls = [for host in flatten([var.site_mappings_auth[each.key].primary_domain_name, var.site_mappings_auth[each.key].alias_domain_names]) : "https://${host}/oauth2/idpresponse"]
  default_redirect_uri = "https://${var.site_mappings_auth[each.key].primary_domain_name}/oauth2/idpresponse"
  allowed_oauth_flows  = ["code"]
  allowed_oauth_scopes = ["openid"]

  supported_identity_providers = ["COGNITO"]
  
  allowed_oauth_flows_user_pool_client = true

  read_attributes  = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo"
  ]

  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo"
  ]

}

data "aws_acm_certificate" "this_auth" {
  for_each = var.site_mappings_auth

  domain = var.site_mappings_auth[each.key].primary_domain_name
  statuses    = ["ISSUED"]
}

resource "aws_lb_listener_certificate" "this_auth" {
  for_each = var.site_mappings_auth
  
  listener_arn    = aws_lb_listener.this_https.arn
  certificate_arn = data.aws_acm_certificate.this_auth[each.key].arn
}

resource "aws_lb_listener_rule" "this_auth" {
  for_each = var.site_mappings_auth

  listener_arn = "${aws_lb_listener.this_https.arn}"

  action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = var.site_mappings_auth[each.key].cognito_user_pool_arn
      user_pool_client_id = aws_cognito_user_pool_client.this_auth[each.key].id
      user_pool_domain    = var.site_mappings_auth[each.key].cognito_user_pool_domain
    }
  }

  action {
    type             = "forward"
    target_group_arn = var.site_mappings_auth[each.key].target_group_arn
  }

  condition {
    host_header {
      values = flatten([var.site_mappings[each.key].primary_domain_name, var.site_mappings[each.key].alias_domain_names])
    }
  }
}
