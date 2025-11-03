# Application Configuration
app_name         = "mysampleapp"
app_version      = "v1.0"
environment      = "production"
container_image  = "priya18082004/myimage:latest"
container_port   = 5000
replicas         = 5
livenessprobe_path = "/"
liveness_probe_initial_delay_seconds = 30
liveness_probe_period_seconds = 10
readinessprobe_path = "/"
readiness_probe_initial_delay_seconds = 15
readiness_probe_period_seconds = 5
efs_volume_mount_name = "efs-storage"
efs_mount_path = "/data"
volume_name = "efs-storage"

# Resource Configuration
cpu_request    = "1000m"
memory_request = "1Gi"
cpu_limit      = "1500m"
memory_limit   = "2Gi"

# Storage Configuration
efs_claim_name = "efs-claim"
efs_storage_request = "5Gi"
efs_storage_limit   = "10Gi"
efs_storage_class   = "efs-sc"
pvc_access_modes    = ["ReadWriteMany"]

# Security Context Configuration
security_context = {
  run_as_non_root            = true
  run_as_user                = 1000
  run_as_group               = 3000
  read_only_root_filesystem  = true
  allow_privilege_escalation = false
  capabilities_drop          = ["ALL"]
}

# PDB Configuration
pdb_name = "pdb"
pdb_min_available = 3

# Annotation Configuration
pvc_annotations = {
  "volume.beta.kubernetes.io/storage-class" = "efs-sc"
}

ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
  "alb.ingress.kubernetes.io/target-type"    = "ip"
  "alb.ingress.kubernetes.io/healthcheck-path" = "/"
  "alb.ingress.kubernetes.io/listen-ports"   = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
  "alb.ingress.kubernetes.io/ssl-redirect"   = "443"
}

# Label Configuration
selector_labels = {
  app = "mysampleapp"
}

deployment_selector_labels = {
  app  = "mysampleapp"
  tier = "frontend"
}

# SSL Certificate Configuration (fallback if ALB DNS not available)
domain_name   = "fallback-domain.com"
tls_algorithm = "RSA"
tls_rsa_bits  = 2048
validation_period = 8760 
aws_region    = "ap-south-1"
cluster_name  = "dev-aws-eks-02-11"
acm_tags = {
  Environment = "production"
  Project     = "mysampleapp"
}

karpenter_provisioner_name  = "karpenter-launched-node"
#Service
service_name = "serivce"
service_labels = {
   app = "mysampleapp"
}
service_type = "NodePort"
service_protocol = "TCP"
service_port = 80

ingress_name = "ingress"
ingress_class_name = "alb"
path_type = "Prefix"
ingress_port = 80
