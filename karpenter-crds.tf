# Fetch and install Karpenter CRDs automatically
data "http" "karpenter_nodepool_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.sh_nodepools.yaml"
}

data "http" "karpenter_nodeclaim_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.sh_nodeclaims.yaml"

}

data "http" "karpenter_ec2nodeclass_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml"
}

resource "kubectl_manifest" "karpenter_nodepool_crd" {
  yaml_body = data.http.karpenter_nodepool_crd.response_body
  force_conflicts = var.karpenter_crd_force_conflicts
  server_side_apply = var.karpenter_crd_server_side_apply
  depends_on = [module.eks]
}

resource "kubectl_manifest" "karpenter_nodeclaim_crd" {
  yaml_body = data.http.karpenter_nodeclaim_crd.response_body
  force_conflicts = var.karpenter_crd_force_conflicts
  server_side_apply = var.karpenter_crd_server_side_apply
  depends_on = [module.eks]
}

resource "kubectl_manifest" "karpenter_ec2nodeclass_crd" {
  yaml_body = data.http.karpenter_ec2nodeclass_crd.response_body
  force_conflicts = var.karpenter_crd_force_conflicts
  server_side_apply = var.karpenter_crd_server_side_apply
  depends_on = [module.eks]
}
