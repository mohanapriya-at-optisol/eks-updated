#!/bin/bash
set -e

# Script to deploy Kubernetes application with auto-detected cluster info

VALUES_FILE="app-values-simple.yaml"
TEMPLATE_FILE="templates/app-simple.yaml"
OUTPUT_FILE="generated-app.yaml"

echo "Getting cluster information from Terraform..."

# Get cluster name and region from Terraform output
CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "")
REGION=$(terraform output -raw region 2>/dev/null || echo "")

# Fallback to manual input if Terraform outputs not available
if [[ -z "$CLUSTER_NAME" ]]; then
    read -p "Enter EKS cluster name: " CLUSTER_NAME
fi

if [[ -z "$REGION" ]]; then
    read -p "Enter AWS region: " REGION
fi

echo "Updating kubeconfig for cluster: $CLUSTER_NAME in region: $REGION"
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

echo "Verifying cluster connection..."
kubectl cluster-info --request-timeout=10s

echo "Generating Kubernetes manifest from template..."

# Parse YAML values and export as environment variables
while IFS=': ' read -r key value; do
  if [[ $key =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] && [[ ! $key =~ ^[[:space:]]*# ]]; then
    # Clean up the value (remove quotes and extra spaces)
    clean_value=$(echo "$value" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/^"//' | sed 's/"$//')
    export "$key"="$clean_value"
  fi
done < <(grep -E '^[a-zA-Z_][a-zA-Z0-9_]*:' "$VALUES_FILE")

# Generate manifest from template
envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "Applying Kubernetes manifest..."
kubectl apply -f "$OUTPUT_FILE"

echo "Application deployed successfully!"
echo "Generated manifest saved as: $OUTPUT_FILE"

# Show deployment status
echo "Checking deployment status..."
kubectl get pods,svc,ingress -l app=$(grep '^app_name:' "$VALUES_FILE" | cut -d':' -f2 | tr -d ' "')