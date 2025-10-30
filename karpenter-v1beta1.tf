# Karpenter v0.37+ (v1beta1 API) - NodePool and EC2NodeClass
resource "kubectl_manifest" "karpenter_nodepool" {
  depends_on = [helm_release.karpenter]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: ${var.karpenter_node_template_name}
    spec:
      template:
        metadata:
          labels:
            karpenter.sh/discovery: ${local.cluster_name}
        spec:
          requirements:
            - key: "karpenter.sh/capacity-type"
              operator: In
              values: ${jsonencode(var.karpenter_capacity_types)}
            - key: "node.kubernetes.io/instance-type"
              operator: In
              values: ${jsonencode(var.karpenter_instance_types)}
          nodeClassRef:
            apiVersion: karpenter.k8s.aws/v1beta1
            kind: EC2NodeClass
            name: ${var.karpenter_node_template_name}
      limits:
        cpu: ${var.karpenter_cpu_limit}
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: ${var.karpenter_ttl_seconds_after_empty}s
  YAML
}

resource "kubectl_manifest" "karpenter_ec2nodeclass" {
  depends_on = [helm_release.karpenter]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: ${var.karpenter_node_template_name}
    spec:
      amiFamily: AL2023
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster_name}
      instanceStorePolicy: RAID0
      userData: |
        #!/bin/bash
        /etc/eks/bootstrap.sh ${local.cluster_name}
      tags:
        karpenter.sh/discovery: ${local.cluster_name}
        Environment: ${var.environment}
        Name: ${var.karpenter_node_template_name}
  YAML
}