resource "aws_iam_role_policy_attachment" "ebs_csi_nodes" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = "upwind-cluster-nodes-eks-node-group-20260211091605345800000009"
}