#!/bin/bash

# Fetch Kubernetes credentials from Azure AKS
echo "Fetching AKS credentials..."
az aks get-credentials --resource-group llm-project --name weaviatevectordb

# Delete existing Kubernetes resources
echo "Deleting existing Kubernetes resources..."
kubectl delete deployment weaviate --ignore-not-found
kubectl delete service weaviate --ignore-not-found
kubectl delete secret weaviate-secret --ignore-not-found
kubectl delete configmap weaviate-config --ignore-not-found

# Apply Kubernetes Secrets
echo "Applying Kubernetes Secrets..."
kubectl apply -f weaviate-secret.yaml

# Apply ConfigMaps
echo "Applying ConfigMaps..."
kubectl apply -f weaviate-config.yaml

# Deploy Weaviate
echo "Deploying Weaviate..."
kubectl apply -f weaviate-deployment.yaml

# Deploy Services
echo "Deploying Services..."
kubectl apply -f weaviate-service.yaml

# Wait until the external IP of the Weaviate service is assigned
echo "Waiting for the Weaviate service to receive an external IP..."
while true; do
  IP=$(kubectl get svc weaviate -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
  if [[ "$IP" && "$IP" != "<none>" && "$IP" != "<pending>" ]]; then
    break
  fi
  echo "Waiting for external IP..."
  sleep 1
done
echo "Weaviate service is now accessible at IP: $IP"
