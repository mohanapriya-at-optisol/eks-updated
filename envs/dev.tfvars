region_name = "ap-south-1"
aws_account_id = "868295556072"
cluster_version = "1.33"
kubectl_apply_retry_count = 5
vpc_cidr = "10.0.0.0/16"
azs = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
public_subnets_range = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets_range = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
intra_subnets_range = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
private_subnet_name = "private_subnet"
public_subnet_name = "public_subnet"
intra_subnet_name = "intra_subnet"
nat_gateway = true
single_nat_gateway = true
one_nat_gateway_per_az = false
enable_dns_support = true
enable_efs_storage = true
node_group_name = "eks-karpenter-mng"
cluster_name = "dev-cluster-sam"
environment = "dev"
enable_eks_public_access = true
enable_eks_private_access = true
enable_admin_permissions = true
irsa = true
kms_alias = "clus-kms-kwy"
node_instance_type = "t3.medium"
node_ami_type = "AL2023_x86_64_STANDARD"
min_size = 2
max_size = 5
desired_size = 2
disk_size = 50
tags = {
  Environment = "dev"
  Project     = "eks-karpenter"
  ManagedBy   = "terraform"
}
mng_tags =  {
  Name = "EKS-Managed-Node-Group"
  NodeGroup = "managed-nodes"
  "k8s.io/cluster-autoscaler/node-template/label/karpenter.sh/discovery" = "dev-new-eks-clus"
}
cluster_sg_tags ={
  Name = "EKS-Cluster-SG"
}
node_sg_tags = {
  Name = "EKS-Node-SG"
}
instance_profile = true

node_iam_role_additional_policies = {
  AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  AmazonEKSWorkerNodePolicy         = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  AmazonEKS_CNI_Policy              = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  EC2InstanceProfileForImageBuilder = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}
karpenter_repo = "oci://public.ecr.aws/karpenter"
helm_chart_name = "karpenter"
karpenter_version = "1.5.0"
karpenter_controller_policy_statements = [
  {
    Effect = "Allow"
    Action = [
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateTags",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DeleteLaunchTemplate",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:ModifyInstanceAttribute",
      "ec2:DescribeInstanceAttribute",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile"
    ]
    Resource = "*"
  },
  {
    Effect = "Allow"
    Action = [
      "iam:PassRole"
    ]
    Resource = "NODE_IAM_ROLE_ARN"
  },
  {
    Effect = "Allow"
    Action = [
      "eks:DescribeCluster"
    ]
    Resource = "CLUSTER_ARN"
  },
  {
    Effect = "Allow"
    Action = [
      "iam:GetInstanceProfile"
    ]
    Resource = "*"
  },
  {
    Effect = "Allow"
    Action = [
      "pricing:GetProducts"
    ]
    Resource = "*"
  },
  {
    Effect = "Allow"
    Action = [
      "ssm:GetParameter"
    ]
    Resource = "arn:aws:ssm:*:*:parameter/aws/service/*"
  },
  {
    Effect = "Allow"
    Action = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]
    Resource = "QUEUE_ARN"
  }
]
helm_create_ns = true
karpenter_capacity_types = ["on-demand"]
karpenter_instance_types = ["m5.large", "m5.xlarge", "m5.2xlarge", "c5.large", "c5.xlarge", "r5.large", "r5.xlarge"]
karpenter_cpu_limit = 1000
karpenter_ttl_seconds_after_empty = 30

security_group_additional_rules = {
  ingress_nodes_ephemeral_ports_tcp = {
    description                = "Allow nodes on ephemeral ports"
    from_port                  = 1025
    to_port                    = 65535
    protocol                   = "tcp"
    type                       = "ingress"
    source_node_security_group = true
    cidr_blocks                = []
  }

  ingress_admin_api = {
    description                = "Allow admin API access"
    from_port                  = 443
    to_port                    = 443
    protocol                   = "tcp"
    type                       = "ingress"
    source_node_security_group = false
    cidr_blocks                = ["203.0.113.0/24"]
  }

  egress_all = {
    description                = "Allow all outbound traffic"
    from_port                  = 0
    to_port                    = 0
    protocol                   = "-1"
    type                       = "egress"
    source_node_security_group = true
    
  }
}

node_security_group_additional_rules = {
  ingress_self_all = {
    description = "Allow node-to-node all ports/protocols"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    type        = "ingress"
    self        = true
  }

}
efs_kms_key_name = "cm-keys"
efs_kms_alias = "efs-cm-kms"
deletion_window = 7
efs_sg_name = "efs-sg"
efs_security_group_rules = [
  {
    name        = "allow_nfs_from_eks_nodes"
    description = "Allow NFS access from EKS worker nodes"
    type        = "ingress"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = []
  },
  {
    name        = "allow_efs_outbound"
    description = "Allow all outbound traffic from EFS"
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

efs_performance = "generalPurpose"
efs_throughput = "bursting"
efs_transition_to_ia = "AFTER_30_DAYS"
encrypt_efs = true
efs_kms_key_tags = {
  Name = "EFS-CM-Keys"
}
efs_sg_tags = {
  Name = "EFS-Security-Group"
}
efs_tags ={
  Name = "dev-new-eks-clus-EFS"
}
efs_creation_token = "efs-for-eks"
efs_csi_driver_name = "aws-efs-csi-driver"
helm_efs_csi_repo = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
helm_efs_csi_charts = "aws-efs-csi-driver"
efs_namespace = "kube-system"
efs_policy_name = "EFS-CSI-POLICY"
efs_role_name = "efs-csi-driver-role"
helm_efs_version = "2.5.7"
storage_class_name = "efs-sc"
provisioning_mode = "efs-ap"
directory_permission = "700"
alb_policy_name = "alb-controller-policy"
alb_policy_tag = {
  Name = "alb-controller-policy"
}
alb_role_name = "alb-controller-role"
alb_controller_name = "aws-load-balancer"
alb_helm_repo = "https://aws.github.io/eks-charts"
alb_chart_name = "aws-load-balancer-controller"
alb_namespace = "kube-system"
alb_sa_name = "alb-controller-sa"
alb_chart_version = "1.6.2"
efs_time_out = 300
efs_cleanup = true
efs_wait = true
efs_wait_for_jobs = true
efs_max_history = 3
eks_max_unavailable_percent = 25
launch_template_creation = true
launch_template_name = "lt"
alb_timeout = 300
alb_cleanup_on_fail = true
alb_wait = true
alb_wait_for_jobs = true
alb_max_history = 3
karpenter_node_template_name = "karpenter-launched-node"
karpenter_consolidation_policy = "WhenEmpty"
karpenter_ami_family = "AL2023"
karpenter_ami_name_pattern = "amazon-eks-node-al2023-x86_64-standard-*"
karpenter_ami_owner = "602401143452"
karpenter_nodeclass_group = "karpenter.k8s.aws"
karpenter_nodeclass_kind = "EC2NodeClass"
karpenter_crd_force_conflicts = true
karpenter_crd_server_side_apply = true


#ALB Policy statements


alb_policy_statements = [
  {
    Effect = "Allow"
    Action = ["iam:CreateServiceLinkedRole"]
    Resource = "*"
    Condition = {
      StringEquals = {
        "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
      }
    }
  },
  {
    Effect = "Allow"
    Action = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags"
    ]
    Resource = "*"
  },
  {
    Effect = "Allow"
    Action = [
      "cognito-idp:DescribeUserPoolClient",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "iam:ListServerCertificates",
      "iam:GetServerCertificate",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:GetSubscriptionState",
      "shield:DescribeProtection",
      "shield:CreateProtection",
      "shield:DeleteProtection"
    ]
    Resource = "*"
  },
  {
    Effect = "Allow"
    Action = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupEgress"
    ]
    Resource = "arn:aws:ec2:*:*:security-group/*"
    Condition = {
      Null = {
        "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
      }
    }
  },
  {
    Effect = "Allow"
    Action = ["ec2:CreateSecurityGroup"]
    Resource = [
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:vpc/*"
    ]
  },
  {
    Effect = "Allow"
    Action = ["ec2:CreateTags"]
    Resource = "arn:aws:ec2:*:*:security-group/*"
    Condition = {
      StringEquals = {
        "ec2:CreateAction" = "CreateSecurityGroup"
      }
      Null = {
        "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
      }
    }
  },
  {
    Effect = "Allow"
    Action = ["ec2:CreateTags", "ec2:DeleteTags"]
    Resource = "arn:aws:ec2:*:*:security-group/*"
    Condition = {
      Null = {
        "aws:RequestTag/elbv2.k8s.aws/cluster" = "true"
        "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
      }
    }
  },
  {
    Effect = "Allow"
    Action = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DeleteSecurityGroup"
    ]
    Resource = "*"
    Condition = {
      Null = {
        "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
      }
    }
  },
  {
    Effect = "Allow"
    Action = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup"
    ]
    Resource = "*"
    Condition = {
      Null = {
        "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
      }
    }
  },
  {
    Effect = "Allow"
    Action = [
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule"
    ]
    Resource = [
      "arn:aws:elasticloadbalancing:*:*:listener/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener/app/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*"
    ]
  },
  {
    Effect = "Allow"
    Action = ["elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags"]
    Resource = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
    ]
    Condition = {
      Null = {
        "aws:RequestTag/elbv2.k8s.aws/cluster" = "true"
        "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
      }
    }
  },
  {
    Effect = "Allow"
    Action = ["elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags"]
    Resource = [
      "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
    ]
  },
  {
    Effect = "Allow"
    Action = [
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:DeleteTargetGroup"
    ]
    Resource = "*"
    Condition = {
      Null = {
        "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
      }
    }
  },
  {
    Effect = "Allow"
    Action = ["elasticloadbalancing:AddTags"]
    Resource = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
    ]
    Condition = {
      StringEquals = {
        "elasticloadbalancing:CreateAction" = ["CreateTargetGroup", "CreateLoadBalancer"]
      }
      Null = {
        "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
      }
    }
  },
  {
    Effect = "Allow"
    Action = ["elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets"]
    Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
  },
  {
    Effect = "Allow"
    Action = [
      "elasticloadbalancing:SetWebAcl",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:ModifyRule"
    ]
    Resource = [
      "arn:aws:elasticloadbalancing:*:*:listener/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener/app/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
    ]
  }
]
alb_policy_version = "2012-10-17"

# EFS Policy Configuration
efs_policy_version = "2012-10-17"

efs_policy_statements = [
  {
    Effect = "Allow"
    Action = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "ec2:DescribeAvailabilityZones"
    ]
    Resource = "*"
  },
  {
    Effect = "Allow"
    Action = ["elasticfilesystem:CreateAccessPoint"]
    Resource = "arn:aws:elasticfilesystem:*:*:file-system/*"
    Condition = {
      StringLike = {
        "aws:RequestTag/efs.csi.aws.com/cluster" = "true"
      }
    }
  },
  {
    Effect = "Allow"
    Action = ["elasticfilesystem:TagResource"]
    Resource = [
      "arn:aws:elasticfilesystem:*:*:file-system/*",
      "arn:aws:elasticfilesystem:*:*:access-point/*"
    ]
    Condition = {
      StringLike = {
        "aws:ResourceTag/efs.csi.aws.com/cluster" = "true"
      }
    }
  },
  {
    Effect = "Allow"
    Action = ["elasticfilesystem:DeleteAccessPoint"]
    Resource = "arn:aws:elasticfilesystem:*:*:access-point/*"
    Condition = {
      StringEquals = {
        "aws:ResourceTag/efs.csi.aws.com/cluster" = "true"
      }
    }
  }
]

karpenter_timeout = 600
karpenter_wait = true
karapenter_wait_for_jobs = true
karpenter_force_update = true
kaprenter_recreate_pods = true
karpenter_skip_crds = false
