locals {
  cluster_name = var.cluster_name
  vpc_name     = "${var.cluster_name}-vpc"
  karpenter_namespace = "${var.environment}-karpenter-namespace"
  karpenter_controller_role_name = "${var.environment}-kc-role"
  karpenter_controller_policy_name = "${var.environment}-kc-policy"
  karpenter_controller_service_acc = "${var.environment}-kc-sa"


#for eks security group
  security_group_additional_rules_final = {
    for rule_name, rule in var.security_group_additional_rules :
    rule_name => merge(
      rule,
      lookup(rule, "source_node_security_group", false)
      ? { cidr_blocks = null } # disable cidr_blocks when SG used
      : {}
    )
  }

#for efs security group
  efs_security_group_rules_final = [
    for rule in var.efs_security_group_rules : merge(
      rule,
      rule.name == "allow_nfs_from_eks_nodes" ?
      { security_groups = [module.eks.node_security_group_id] } :
      {}
    )
  ]
  
}
