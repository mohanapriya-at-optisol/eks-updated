# Application Configuration
variable "app_name" {
  description = "Application name"
  type        = string
  default     = "mysampleapp"
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "v1.0"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "acm_tags"{
  description = "Tags for ACM Certificate"
  type        = map(string)
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "livenessprobe_path"{
  description = "Liveness probe path"
  type = string
}

variable "liveness_probe_initial_delay_seconds"{
  description = "Initial delay seconds"
  type = number

}
variable "liveness_probe_period_seconds"{
  description = "Liveness probe period seconds"
  type = number
}

variable "readinessprobe_path"{
  description = "Readiness probe path"
  type = string

}
variable "readiness_probe_initial_delay_seconds"{
  description = "Initial delay seconds"
  type = number

}
variable "readiness_probe_period_seconds"{
  description = "Readiness probe period seconds"
  type = number
}
variable "container_port" {
  description = "Container port"
  type        = number
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
  
}

variable "efs_volume_mount_name"{
  description = "EFS volume mount name"
  type = string
}
variable "efs_mount_path"{
  description = "EFS mount path"
  type = string
}

variable "volume_name"{
  description = "Volume name"
  type = string
}
# Resource Configuration
variable "cpu_request" {
  description = "CPU request"
  type        = string
}

variable "memory_request" {
  description = "Memory request"
  type        = string
  
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
  
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
  
}

# Storage Configuration
variable "efs_claim_name"{
  description = "Name of EFS Claim"
  type = string
}
variable "efs_storage_request" {
  description = "EFS storage request"
  type        = string

}

variable "efs_storage_limit" {
  description = "EFS storage limit"
  type        = string
  
}

variable "efs_storage_class" {
  description = "EFS storage class"
  type        = string
  
}

variable "pvc_access_modes" {
  description = "PVC access modes"
  type        = list(string)
}

# Security Context Configuration
variable "security_context" {
  description = "Container security context"
  type = object({
    run_as_non_root            = bool
    run_as_user                = number
    run_as_group               = number
    read_only_root_filesystem  = bool
    allow_privilege_escalation = bool
    capabilities_drop          = list(string)
  })
}

# PDB Configuration
variable "pdb_name"{
  description = "PDB name"
  type = string
}
variable "pdb_min_available" {
  description = "PDB minimum available pods"
  type        = number
  
}

# Annotation Configuration
variable "pvc_annotations" {
  description = "PVC annotations"
  type        = map(string)
}

variable "ingress_annotations" {
  description = "Ingress annotations"
  type        = map(string)
}

# Label Configuration
variable "selector_labels" {
  description = "Selector labels for matching resources"
  type        = map(string)
}

variable "deployment_selector_labels" {
  description = "Deployment selector labels"
  type        = map(string)
}

# SSL Certificate Configuration
variable "domain_name" {
  description = "Domain name for SSL certificate"
  type        = string
  
}

variable "tls_algorithm" {
  description = "TLS private key algorithm"
  type        = string
}

variable "tls_rsa_bits" {
  description = "RSA key size in bits"
  type        = number
}

variable "validation_period"{
  description = "Certificate validation period in hours"
  type        = number
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "karpenter_provisioner_name" {
  description = "Karpenter nodepool name"
  type        = string
  
}

#Service
variable "service_name"{
  description = "Service Name"
  type = string
}
variable "service_labels"{
  description = "Service Labels"
  type  = map(string)
}
variable "service_type"{
  description = "Service Type"
  type = string
}
variable "service_protocol"{
  description = "Service Protocol"
  type = string

}
variable "service_port"{
  description = "Service Port"
  type = number
}

variable "ingress_name"{
  description = "Ingress Name"
  type = string

}
variable "ingress_class_name"{
  description = "Ingress Class Name"
  type = string
}

variable "path_type"{
  description = "Path type for ingress"
  type = string
}

variable "ingress_port"{
  description = "Ingress Port"
  type = number

}
