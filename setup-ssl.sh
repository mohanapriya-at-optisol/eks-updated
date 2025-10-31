#!/bin/bash

echo "Setting up Let's Encrypt SSL for ALB..."

# Step 1: Deploy initial HTTP application
echo "1. Deploying HTTP application..."
kubectl apply -f generated-app.yaml

# Step 2: Wait for ALB to be ready
echo "2. Waiting for ALB to be provisioned..."
kubectl wait --for=condition=ready ingress/mysampleapp-ingress --timeout=300s

# Step 3: Get ALB DNS name
echo "3. Getting ALB DNS name..."
ALB_DNS=$(kubectl get ingress mysampleapp-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$ALB_DNS" ]; then
    echo "Error: ALB DNS name not found. Please check ingress status."
    exit 1
fi

echo "ALB DNS Name: $ALB_DNS"

# Step 4: Generate SSL-enabled ingress with ALB DNS
echo "4. Generating SSL-enabled ingress..."
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

# Step 5: Apply SSL-enabled ingress
echo "5. Applying SSL-enabled ingress..."
kubectl apply -f generated-ssl-ingress.yaml

echo "SSL setup complete!"
echo "Your application will be available at: https://$ALB_DNS"
echo "Certificate provisioning may take 2-3 minutes..."