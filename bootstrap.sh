#!/bin/bash
set -e

# EKS Node Bootstrap Script
# Variables passed from Terraform:
# - cluster_name: ${cluster_name}
# - api_server_url: ${api_server_url}
# - cluster_ca: ${cluster_ca}

# Run EKS bootstrap script
/etc/eks/bootstrap.sh "${cluster_name}" \
  --apiserver-endpoint "${api_server_url}" \
  --b64-cluster-ca "${cluster_ca}"

echo "EKS node bootstrap completed successfully"