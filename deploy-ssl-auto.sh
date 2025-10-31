#!/bin/bash

echo "=== SSL Deployment with Template System ==="

# Step 1: Deploy HTTP app first using existing template
echo "1. Deploying HTTP application..."
./deploy-app-auto.sh
kubectl apply -f generated-app.yaml

# Step 2: Wait for ALB DNS to be available
echo "2. Waiting for ALB DNS to be available..."
for i in {1..30}; do
    ALB_DNS=$(kubectl get ingress mysampleapp-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    if [ ! -z "$ALB_DNS" ]; then
        echo "ALB DNS found: $ALB_DNS"
        break
    fi
    echo "Waiting for ALB DNS... (attempt $i/30)"
    sleep 10
done

if [ -z "$ALB_DNS" ]; then
    echo "Error: ALB DNS name not found after 5 minutes"
    exit 1
fi

# Step 3: ALB DNS obtained

# Step 4: Generate SSL-enabled app using template system
echo "4. Generating SSL-enabled application..."

# Read values from app-values-simple.yaml and add ALB DNS
python3 << EOF
import yaml

# Load existing values
with open('app-values-simple.yaml', 'r') as f:
    values = yaml.safe_load(f)

# Add ALB DNS name
values['alb_dns_name'] = '$ALB_DNS'

# Load template
with open('templates/app-ssl.yaml', 'r') as f:
    template = f.read()

# Replace variables
for key, value in values.items():
    template = template.replace(f'\${{{key}}}', str(value))

# Write SSL-enabled YAML
with open('generated-ssl-app.yaml', 'w') as f:
    f.write(template)

print("SSL-enabled YAML generated successfully")
EOF

# Step 5: Apply SSL-enabled application
echo "5. Applying SSL-enabled application..."
kubectl apply -f generated-ssl-app.yaml

echo "=== SSL Setup Complete ==="
echo "HTTP URL:  http://$ALB_DNS"
echo "HTTPS URL: https://$ALB_DNS"
echo "Certificate provisioning may take 2-3 minutes..."