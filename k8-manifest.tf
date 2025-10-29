resource "kubernetes_manifest" "pvc" {
  manifest = yamldecode(templatefile("${path.module}/templates/pvc.yaml.tmpl", {
    pvc_name        = var.pvc_name
    pvc_annotations = var.pvc_annotations
    storage_class   = var.storage_class
    access_mode     = var.access_mode
    storage_request = var.storage_request
    storage_limit   = var.storage_limit
  }))
}

resource "kubernetes_manifest" "pdb" {
  manifest = yamldecode(templatefile("${path.module}/templates/pdb.yaml.tmpl", {
    pdb_name           = var.pdb_name
    pdb_min_available  = var.pdb_min_available
    pdb_selector_label = var.pdb_selector_label
  }))
}

resource "kubernetes_manifest" "deployment" {
  manifest = yamldecode(templatefile("${path.module}/templates/deployment.yaml.tmpl", {
    deployment_name              = var.deployment_name
    deployment_labels             = var.deployment_labels
    deployment_replicas           = var.deployment_replicas
    deployment_selector_labels    = var.deployment_selector_labels
    deployment_app_labels         = var.deployment_app_labels
    deployment_container_name     = var.deployment_container_name
    deployment_container_image    = var.deployment_container_image
    deployment_container_port     = var.deployment_container_port
    run_as_user                   = var.run_as_user
    run_as_group                  = var.run_as_group
    liveness_path                 = var.liveness_path
    liveness_probe_port           = var.liveness_probe_port
    liveness_initial_delay        = var.liveness_initial_delay
    liveness_period               = var.liveness_period
    readiness_path                = var.readiness_path
    readiness_probe_port          = var.readiness_probe_port
    readiness_initial_delay       = var.readiness_initial_delay
    readiness_period              = var.readiness_period
    cpu_request                   = var.cpu_request
    memory_request                = var.memory_request
    cpu_limit                     = var.cpu_limit
    memory_limit                  = var.memory_limit
    volume_name                   = var.volume_name
    mount_path                    = var.mount_path
    pvc_name                      = var.pvc_name
  }))
}

resource "kubernetes_manifest" "service" {
  manifest = yamldecode(templatefile("${path.module}/templates/service.yaml.tmpl", {
    service_name            = var.service_name
    service_labels           = var.service_labels
    service_type             = var.service_type
    service_selector_labels  = var.service_selector_labels
    service_protocol         = var.service_protocol
    service_port             = var.service_port
    service_target_port      = var.service_target_port
  }))
}

resource "kubernetes_manifest" "ingress" {
  manifest = yamldecode(templatefile("${path.module}/templates/ingress.yaml.tmpl", {
    ingress_name        = var.ingress_name
    ingress_annotations = var.ingress_annotations
    ingress_class       = var.ingress_class
    ingress_path        = var.ingress_path
    path_type           = var.path_type
    service_name        = var.service_name
    service_port        = var.service_port
  }))
}
