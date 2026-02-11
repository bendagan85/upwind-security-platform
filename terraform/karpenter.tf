module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  cluster_name = module.eks.cluster_name

  node_iam_role_use_name_prefix = false
  node_iam_role_name            = "KarpenterNodeRole-${var.cluster_name}"

  create_access_entry = true

  tags = {
    Name = "karpenter"
  }
}