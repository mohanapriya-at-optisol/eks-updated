output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.ssl_cert.arn
}

output "certificate_domain" {
  description = "Domain name of the certificate"
  value       = "*.elb.amazonaws.com"
}

output "alb_dns_name" {
  description = "ALB DNS name from ingress"
  value       = try(kubernetes_ingress_v1.app_ingress.status[0].load_balancer[0].ingress[0].hostname, "pending")
}

output "kubectl_commands" {
  description = "Useful kubectl commands"
  value = {
    check_pods = "kubectl get pods -l app=${var.app_name} -o wide"
    describe_deployment = "kubectl describe deployment ${var.app_name}"
    check_nodes = "kubectl get nodes"
  }
}

output "curl_commands" {
  description = "Commands to test application accessibility"
  value = {
    https_url = "curl -k https://${try(kubernetes_ingress_v1.app_ingress.status[0].load_balancer[0].ingress[0].hostname, "ALB-DNS-PENDING")}"
    http_url = "curl http://${try(kubernetes_ingress_v1.app_ingress.status[0].load_balancer[0].ingress[0].hostname, "ALB-DNS-PENDING")}"
    https_verbose = "curl -k -v https://${try(kubernetes_ingress_v1.app_ingress.status[0].load_balancer[0].ingress[0].hostname, "ALB-DNS-PENDING")}"
    service_port_forward = "kubectl port-forward service/${kubernetes_service.app_service.metadata[0].name} 8080:80"
    curl_port_forward = "curl http://localhost:8080"
  }
}

output "app_service_name" {
  description = "Name of the Kubernetes service"
  value       = kubernetes_service.app_service.metadata[0].name
}

output "ingress_name" {
  description = "Name of the Kubernetes ingress"
  value       = kubernetes_ingress_v1.app_ingress.metadata[0].name
}

