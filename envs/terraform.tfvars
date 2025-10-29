
pvc_name        = "efs-claim"
pvc_annotations = {
  "volume.beta.kubernetes.io/storage-class" = "efs-sc"
}
storage_class   = "efs-sc"
access_mode     = "ReadWriteMany"
storage_request = "5Gi"
storage_limit   = "10Gi"

# ---------------------
# Pod Disruption Budget
# ---------------------
pdb_name          = "mysampleapp-pdb"
pdb_min_available = 3
pdb_selector_label = {
  app = "mysampleapp"
}

# ---------------------
# Deployment
# ---------------------
deployment_name = "mysampleapp"

deployment_labels = {
  app = "mysampleapp"
}

deployment_replicas = 5

deployment_app_labels = {
  app = "mysampleapp"
  env = "mysamplelabel"
}

deployment_selector_labels = {
  app = "mysampleapp"
}

deployment_container_name  = "mycontainer"
deployment_container_image = "priya18082004/myimage:latest"
deployment_container_port  = 5000

run_as_user  = 1000
run_as_group = 3000

# Probes
liveness_path          = "/"
liveness_probe_port    = 5000
liveness_initial_delay = 30
liveness_period        = 10

readiness_path          = "/"
readiness_probe_port    = 5000
readiness_initial_delay = 5
readiness_period        = 5

# Resource requests/limits
cpu_request   = "1000m"
memory_request = "512Mi"
cpu_limit     = "1500m"
memory_limit  = "1Gi"

# Volume mounts
volume_name = "efs-storage"
mount_path  = "/data"


# ---------------------
# Service
# ---------------------
service_name = "mysampleapp-service"

service_labels = {
  app = "mysampleapp"
}

service_type = "NodePort"

service_selector_labels = {
  app = "mysampleapp"
}

service_protocol    = "TCP"
service_port        = 80
service_target_port = 5000

# ---------------------
# Ingress
# ---------------------
ingress_name = "mysampleapp-ingress"

ingress_annotations = {
  "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
  "alb.ingress.kubernetes.io/target-type"     = "ip"
  "alb.ingress.kubernetes.io/healthcheck-path" = "/"
  "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
  "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
}

ingress_class = "alb"
ingress_path  = "/"
path_type     = "Prefix"
