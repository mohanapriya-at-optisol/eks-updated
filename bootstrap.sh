#!/bin/bash
set -e

# EKS Node Bootstrap Script
echo "Starting EKS node bootstrap..."

# Variables from Terraform template
CLUSTER_NAME="${cluster_name}"
API_SERVER_URL="${api_server_url}"
CLUSTER_CA="${cluster_ca}"

# Validate variables
if [[ -z "$CLUSTER_NAME" ]]; then
    echo "Error: CLUSTER_NAME is not set" >&2
    exit 1
fi

# Run EKS bootstrap script
/etc/eks/bootstrap.sh "$CLUSTER_NAME" \
  --apiserver-endpoint "$API_SERVER_URL" \
  --b64-cluster-ca "$CLUSTER_CA"

echo "EKS node bootstrap completed successfully"
