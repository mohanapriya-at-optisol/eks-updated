#!/bin/bash

echo "=== Complete EKS + SSL Deployment ==="

# Step 1: Deploy Infrastructure
echo "1. Deploying EKS infrastructure..."
terraform init
terraform plan -var-file="envs/dev.tfvars"
terraform apply -var-file="envs/dev.tfvars" -auto-approve

if [ $? -ne 0 ]; then
    echo "Error: Terraform deployment failed"
    exit 1
fi

# Step 2: Configure kubectl
echo "2. Configuring kubectl..."
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)

# Step 3: Wait for cluster to be ready
echo "3. Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Step 4: Generate application YAML
echo "4. Generating application YAML..."
./deploy-app-auto.sh

# Step 5: Deploy HTTP application first
echo "5. Deploying HTTP application..."
kubectl apply -f generated-app.yaml

# Step 6: Wait for ALB to be provisioned
echo "6. Waiting for ALB provisioning..."
kubectl wait --for=condition=ready ingress/mysampleapp-ingress --timeout=600s

# Step 7: Get ALB DNS name
echo "7. Getting ALB DNS name..."
ALB_DNS=$(kubectl get ingress mysampleapp-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$ALB_DNS" ]; then
    echo "Error: ALB DNS name not found"
    exit 1
fi

echo "ALB DNS Name: $ALB_DNS"

# Step 8: Wait for cert-manager to be ready
echo "8. Waiting for cert-manager..."
kubectl wait --for=condition=Available deployment/cert-manager -n cert-manager --timeout=300s
kubectl wait --for=condition=Available deployment/cert-manager-webhook -n cert-manager --timeout=300s

# Step 9: Generate and apply SSL ingress
echo "9. Enabling SSL with Let's Encrypt..."
cat > generated-ssl-ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mysampleapp-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-path: /
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: alb
  tls:
  - hosts:
    - $ALB_DNS
    secretName: mysampleapp-tls
  rules:
  - host: $ALB_DNS
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mysampleapp-service
            port:
              number: 80
EOF

kubectl apply -f generated-ssl-ingress.yaml

echo "=== Deployment Complete ==="
echo "HTTP URL:  http://$ALB_DNS"
echo "HTTPS URL: https://$ALB_DNS"
echo "Certificate provisioning may take 2-3 minutes..."

# Step 10: Monitor certificate status
echo "10. Monitoring certificate status..."
kubectl get certificate mysampleapp-tls -w