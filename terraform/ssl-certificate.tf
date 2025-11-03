# Generate private key
resource "tls_private_key" "ssl_key" {
  algorithm = var.tls_algorithm
  rsa_bits  = var.tls_rsa_bits
}

# Generate self-signed certificate with wildcard for ALB
resource "tls_self_signed_cert" "ssl_cert" {
  private_key_pem = tls_private_key.ssl_key.private_key_pem

  subject {
    common_name  = "*.elb.amazonaws.com"
    organization = "Self Signed"
  }

  dns_names = ["*.elb.amazonaws.com", "*.elb.*.amazonaws.com"]

  validity_period_hours = var.validation_period

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Import certificate to ACM
resource "aws_acm_certificate" "ssl_cert" {
  private_key      = tls_private_key.ssl_key.private_key_pem
  certificate_body = tls_self_signed_cert.ssl_cert.cert_pem

  tags = var.acm_tags
}
