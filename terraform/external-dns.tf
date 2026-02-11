resource "aws_route53_zone" "main" {
  name = "ckicl.xyz"

  tags = {
    Name = "ckicl.xyz"
  }
}

module "external_dns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "external-dns"

  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = {
    Name = "external-dns-irsa"
  }
}

output "nameservers" {
  value = aws_route53_zone.main.name_servers
}

output "hosted_zone_id" {
  value = aws_route53_zone.main.zone_id
}