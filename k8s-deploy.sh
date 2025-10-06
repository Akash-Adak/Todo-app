#!/bin/bash

set -e

echo "Deploying Todo App to Kubernetes..."

# Create namespace
kubectl apply -f namespace.yaml

# Create configmap
kubectl apply -f configmap.yaml

# Create deployment
kubectl apply -f deployment.yaml

# Create service
kubectl apply -f service.yaml

# Create ingress (if needed)
kubectl apply -f ingress.yaml

# Wait for rollout to complete
kubectl rollout status deployment/todo-app -n todo-app

echo "Deployment completed successfully!"
echo "Access the app at: http://todo-app.local"