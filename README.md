# alb-public-web
alb-public-web is used to make a load balancer for standard 80/443 traffic which can automatically redirect all traffic to the secure port (443). The module uses a map of maps to be able to define multiple sites behind the same ALB (Maximum of 25!) to help with cost.

You must define the target group outside of this ALB module and then add it in your site_mapping. This is to support different combinations of sites/target groups.

There must also be an already existing, and successfully issued/imported ACM certificate which can be attached to the https ALB listener.

This module outputs the id of a security group which you can add targets to in order to allow them to be reached by the ALB.

SSL Security Policies can be found here: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies

TODO:
- Support paths by coalescing a default of /* and allowing an override to be passed in as a site_mapping variable?
- Creating SGs per mapping and then attaching explicitly instead of with a single to support specific port mappings?

### Example Usage:
Create a default role with permissions for ssm and cloudwatch agent:
```
module "alb-public-web" {
  source  = "GenesisFunction/alb-public-web/aws"
  version = "1.0.0"
  # source  = "github.com/GenesisFunction/terraform-aws-alb-public-web"

  alb_name         = "${var.name_prefix}-app-01${local.name_suffix}"
  vpc_id           = module.vpc_app.vpc_id
  subnet_ids       = module.vpc_app.public_subnets
  log_bucket_id    = local.log_bucket
  security_policy  = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_acm_certificate_arn = data.aws_acm_certificate.this.arn
  site_mappings = {
    my-app-com = {
      primary_domain_name = my.app.com
      alias_domain_names  = []
      target_group_arn    = module.asg_shop_funinow_uk.asg_target_group_id
    }
    other-app-com = {
      primary_domain_name = other.app.com
      alias_domain_names  = []
      target_group_arn    = module.asg_shop_funinow_uk.asg_target_group_id
    }
  }

  input_tags = merge(local.common_tags, {})
}
```
