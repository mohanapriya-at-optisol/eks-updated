module "eks" {
  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v21.3.1"
  
  name               = var.cluster_name
  kubernetes_version = var.cluster_version
  endpoint_public_access = var.enable_eks_public_access
  endpoint_private_access = var.enable_eks_private_access
  enable_cluster_creator_admin_permissions = var.enable_admin_permissions

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }
 
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets
  
  enable_irsa = var.irsa
  
  # Custom KMS key alias to avoid conflicts
  kms_key_aliases = ["alias/${local.cluster_name}-${var.kms_alias}"]
  
  # Apply tags to EKS cluster
  tags = var.tags
  
  #EKS MANAGED NODE GROUP
  eks_managed_node_groups = {
    "${var.node_group_name}" = {
      ami_type       = var.node_ami_type
      instance_types = [var.node_instance_type]
 
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size
      
      disk_size = var.disk_size  # Uses 50GB from your tfvars
      
      update_config = {
      max_unavailable_percentage = var.eks_max_unavailable_percent
    }
    
    # Add launch template for better control
    create_launch_template = var.launch_template_creation
    launch_template_name   = "${var.cluster_name}-${var.node_group_name}-${var.launch_template_name}"
    
    # Custom user data with bootstrap script
    user_data = base64encode(templatefile("${path.module}/bootstrap.sh", {
      cluster_name   = var.cluster_name
      api_server_url = module.eks.cluster_endpoint
      cluster_ca     = module.eks.cluster_certificate_authority_data
    }))
    
    
      # Apply tags to managed node group
      tags = merge(local.common_tags,var.mng_tags)
    }
  }

   security_group_tags = merge(local.common_tags, var.cluster_sg_tags)


   security_group_additional_rules = local.security_group_additional_rules_final

   node_security_group_tags = merge(local.common_tags, var.node_sg_tags, {
     "elbv2.k8s.aws/cluster" = var.cluster_name
   })


 node_security_group_additional_rules = {
  for rule_name, rule in var.node_security_group_additional_rules :
  rule_name => {
    description          = rule.description
    from_port            = rule.from_port
    to_port              = rule.to_port
    protocol             = rule.protocol
    type                 = rule.type
    self                 = rule.self
    cidr_blocks          = rule.cidr_blocks
  }
}
  
}
