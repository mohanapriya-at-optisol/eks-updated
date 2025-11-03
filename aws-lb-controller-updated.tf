# IAM Policy for AWS Load Balancer Controller - Updated with Egress and Listener permissions

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${local.cluster_name}-${var.alb_policy_name}"
  
  lifecycle {
    create_before_destroy = true
  }
  policy = jsonencode({
    Version = var.alb_policy_version
    Statement = var.alb_policy_statements
  })

  tags = merge(local.general_tags, var.alb_policy_tag)
}

# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "${local.cluster_name}-${var.alb_role_name}"

  assume_role_policy = jsonencode({
    Version = var.alb_policy_version
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:${local.cluster_name}-${var.alb_sa_name}"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
  role       = aws_iam_role.aws_load_balancer_controller.name
}

# Kubernetes Service Account for AWS Load Balancer Controller
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "${local.cluster_name}-${var.alb_sa_name}"
    namespace = var.alb_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
    }
  }

  depends_on = [module.eks]
}

# Install AWS Load Balancer Controller via Helm
resource "helm_release" "aws_load_balancer_controller" {
  name       = "${local.cluster_name}-${var.alb_controller_name}"
  repository = var.alb_helm_repo
  chart      = var.alb_chart_name
  namespace  = var.alb_namespace
  version    = var.alb_chart_version
 
  # Add error handling
  timeout         = var.alb_timeout
  cleanup_on_fail = var.alb_cleanup_on_fail
  wait            = var.alb_wait
  wait_for_jobs   = var.alb_wait_for_jobs
  max_history     = var.alb_max_history

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
  }

  set {
    name  = "region"
    value = var.region_name
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key"
    value = "eks.amazonaws.com/nodegroup"
  }

  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator"
    value = "Exists"
  }

  depends_on = [
    module.eks,
    kubernetes_service_account.aws_load_balancer_controller,
    aws_iam_role_policy_attachment.aws_load_balancer_controller
  ]
}
