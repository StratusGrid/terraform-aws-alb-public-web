<!-- BEGIN_TF_DOCS -->
<p align="center">                                                                                                                                            
                                                                                
  <img src="https://github.com/StratusGrid/terraform-readme-template/blob/main/header/stratusgrid-logo-smaller.jpg?raw=true" />
  <p align="center">                                                           
    <a href="https://stratusgrid.com/book-a-consultation">Contact Us</a> |                  
    <a href="https://stratusgrid.com/cloud-cost-optimization-dashboard">Stratusphere FinOps</a> |
    <a href="https://stratusgrid.com">StratusGrid Home</a> |
    <a href="https://stratusgrid.com/blog">Blog</a>
  </p>                    
</p>

 # terraform-aws-alb-public-web
 GitHub: [StratusGrid/terraform-aws-alb-public-web](https://github.com/StratusGrid/terraform-aws-alb-public-web)

 alb-public-web is used to make a load balancer for standard 80/443 traffic which can automatically redirect all traffic to the secure port (443). The module uses a map of maps to be able to define multiple sites behind the same ALB (Maximum of 25!) to help with cost.
 This module also has the ability to add a cognito pool in front of individual sites/applications on a per listener rule basis.
 You must define the target group outside of this ALB module and then add it in your site_mapping. This is to support different combinations of sites/target groups.
 There must also be an already existing, and successfully issued/imported ACM certificate which can be attached to the https ALB listener.
 This module outputs the id of a security group which you can add targets to in order to allow them to be reached by the ALB.

 SSL Security Policies can be found here: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies

 TODO:
 - Support paths by coalescing a default of /* and allowing an override to be passed in as a site_mapping variable?
 - Creating SGs per mapping and then attaching explicitly instead of with a single to support specific port mappings?

 After code merges, come and make changes needed to properly support lists of host headers
 Syntax that supports multiple values in list after merge of: https://github.com/terraform-providers/terraform-provider-aws/pull/8268
 More info: https://github.com/terraform-providers/terraform-provider-aws/issues/8126
 Already in code but commented out:
 condition {
   host_header = flatten([var.site_mappings[each.key].primary_domain_name, var.site_mappings[each.key].alias_domain_names])
 }
 
 ## Example
 ```hcl
 module "alb-public-web" {
  source  = "GenesisFunction/alb-public-web/aws"
  version = "1.1.5"
  # source  = "github.com/GenesisFunction/terraform-aws-alb-public-web"

  alb_name         = "${var.name_prefix}-app-01${local.name_suffix}"
  vpc_id           = module.vpc_app.vpc_id
  subnet_ids       = module.vpc_app.public_subnets
  log_bucket_id    = local.log_bucket
  security_policy  = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_acm_certificate_arn = data.aws_acm_certificate.this.arn

  #Site mappings which just have a forward action for anything that matches the host header
  site_mappings = {
    my-app-com = {
      primary_domain_name = my.app.com
      alias_domain_names  = []
      target_group_arn    = module.asg_my_app_com.asg_target_group_id
    }
    other-app-com = {
      primary_domain_name = other.app.com
      alias_domain_names  = []
      target_group_arn    = module.asg_other_app_com.asg_target_group_id
    }
  }

  #Site mappings which will also require the user to successfully authenticate with cognito
  site_mappings_auth = {
    prerelease-app-com = {
      primary_domain_name = prerelease.app.com
      alias_domain_names  = []
      target_group_arn    = module.asg_prerelease_app_com.asg_target_group_id
      cognito_user_pool_arn       = aws_cognito_user_pool.prerelease.arn
      cognito_user_pool_domain    = aws_cognito_user_pool_domain.prerelease.id
  }

  input_tags = merge(local.common_tags, {})
}
 ```
 ## StratusGrid Standards we assume
 - All resource names and name tags shall use `_` and not `-`s
 - The old naming standard for common files such as inputs, outputs, providers, etc was to prefix them with a `-`, this is no longer true as it's not POSIX compliant. Our pre-commit hooks will fail with this old standard.
 - StratusGrid generally follows the TerraForm standards outlined [here](https://www.terraform-best-practices.com/naming)
 ## Repo Knowledge
 Repository for Module vmimport
 ## Documentation
 This repo is self documenting via Terraform Docs, please see the note at the bottom.
 ### `LICENSE`
 This is the standard Apache 2.0 License as defined [here](https://stratusgrid.atlassian.net/wiki/spaces/TK/pages/2121728017/StratusGrid+Terraform+Module+Requirements).
 ### `outputs.tf`
 The StratusGrid standard for Terraform Outputs.
 ### `README.md`
 It's this file! I'm always updated via TF Docs!
 ### `tags.tf`
 The StratusGrid standard for provider/module level tagging. This file contains logic to always merge the repo URL.
 ### `variables.tf`
 All variables related to this repo for all facets.
 One day this should be broken up into each file, maybe maybe not.
 ### `versions.tf`
 This file contains the required providers and their versions. Providers need to be specified otherwise provider overrides can not be done.
 ## Documentation of Misc Config Files
 This section is supposed to outline what the misc configuration files do and what is there purpose
 ### `.config/.terraform-docs.yml`
 This file auto generates your `README.md` file.
 ### `.github/workflows/pre-commit.yml`
 This file contains the instructions for Github workflows, in specific this file run pre-commit and will allow the PR to pass or fail. This is a safety check and extras for if pre-commit isn't run locally.
 ### `examples/*`
 The files in here are used by `.config/terraform-docs.yml` for generating the `README.md`. All files must end in `.tfnot` so Terraform validate doesn't trip on them since they're purely example files.
 ### `.gitignore`
 This is your gitignore, and contains a slew of default standards.
 ---
 ## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |
 ## Resources

| Name | Type |
|------|------|
| [aws_cognito_user_pool_client.this_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.this_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.this_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_listener_certificate.this_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.this_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_security_group.this_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.this_targets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this_alb_egress_to_internet_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_alb_egress_to_targets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_alb_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_alb_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
 ## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Unique string name of ALB to be created. Also prepends supporting resource names | `string` | n/a | yes |
| <a name="input_default_acm_certificate_arn"></a> [default\_acm\_certificate\_arn](#input\_default\_acm\_certificate\_arn) | Certificate that is used for default https action | `string` | n/a | yes |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | whether or not to enable deletion protection on the ALB. Defaults to true | `bool` | `true` | no |
| <a name="input_input_tags"></a> [input\_tags](#input\_input\_tags) | Map of tags to apply to resources | `map(string)` | <pre>{<br>  "Developer": "GenesisFunction",<br>  "Provisioner": "Terraform"<br>}</pre> | no |
| <a name="input_internal_only"></a> [internal\_only](#input\_internal\_only) | true/false of whether load balancer should be internal only (no elastic IPs). Default is false | `bool` | `false` | no |
| <a name="input_log_bucket_id"></a> [log\_bucket\_id](#input\_log\_bucket\_id) | ID of logging bucket to be targeted alb logs | `string` | n/a | yes |
| <a name="input_log_prefix"></a> [log\_prefix](#input\_log\_prefix) | common prefix to place logs into. elb would become elb/alb\_name/LOGS | `string` | `"elb"` | no |
| <a name="input_security_policy"></a> [security\_policy](#input\_security\_policy) | ALB Security Policy - determines supported TLS versions and ciphers for ALL SITES. Default is TLS 1.2 only | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_site_mappings"></a> [site\_mappings](#input\_site\_mappings) | A map of maps for each site active on the ALB. Maximum of 25 site mappings per ALB!. | <pre>map(object(<br>    {<br>      primary_domain_name = string<br>      alias_domain_names  = list(string)<br>      target_group_arn    = string<br>    }<br>  ))</pre> | `{}` | no |
| <a name="input_site_mappings_auth"></a> [site\_mappings\_auth](#input\_site\_mappings\_auth) | A map of maps for each site active on the ALB which has authentication via cognito. Maximum of 25 site mappings per ALB!. | <pre>map(object(<br>    {<br>      primary_domain_name      = string<br>      alias_domain_names       = list(string)<br>      target_group_arn         = string<br>      cognito_user_pool_arn    = string<br>      cognito_user_pool_domain = string<br>    }<br>  ))</pre> | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | IDs of Subnets which the alb should be attached to | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC which the resource should be created in | `string` | n/a | yes |
 ## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS Name of ALB |
| <a name="output_sg_alb_targets_id"></a> [sg\_alb\_targets\_id](#output\_sg\_alb\_targets\_id) | ID of security group which ALB targets are added to for ALB to have access |
 ---
 Note, manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml`
<!-- END_TF_DOCS -->