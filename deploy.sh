#!/bin/bash

set -e

DOCKER_USERNAME="axelfrache"
SERVICE_A_IMAGE="$DOCKER_USERNAME/service-a:latest"
SERVICE_B_IMAGE="$DOCKER_USERNAME/service-b:latest"

echo "Début du déploiement de l'application microservices"

if [ ! -d "service-a" ] || [ ! -d "service-b" ]; then
    echo "ERREUR: Les dossiers service-a et service-b n'existent pas"
    echo "Assurez-vous d'exécuter ce script depuis le répertoire racine du projet"
    exit 1
fi

echo "Construction de l'image Service A..."
cd service-a
docker build -t $SERVICE_A_IMAGE .
cd ..

echo "Construction de l'image Service B..."
cd service-b
docker build -t $SERVICE_B_IMAGE .
cd ..

echo "Push des images vers Docker Hub..."
echo "Assurez-vous d'être connecté à Docker Hub (docker login)"
docker push $SERVICE_A_IMAGE
docker push $SERVICE_B_IMAGE

echo "Déploiement sur Kubernetes..."

if ! kubectl cluster-info &> /dev/null; then
    echo "ERREUR: Impossible de se connecter au cluster Kubernetes"
    echo "Vérifiez votre kubeconfig"
    exit 1
fi

echo "Déploiement du Service B..."
kubectl apply -f k8s/service-b.yaml

echo "Attente que le Service B soit prêt..."
kubectl wait --for=condition=available --timeout=300s deployment/service-b

echo "Déploiement du Service A..."
kubectl apply -f k8s/service-a.yaml

echo "Attente que le Service A soit prêt..."
kubectl wait --for=condition=available --timeout=300s deployment/service-a

echo "Statut des déploiements:"
kubectl get deployments
echo ""
kubectl get services
echo ""
kubectl get pods

echo ""
echo "Récupération de l'URL d'accès..."
EXTERNAL_IP=$(kubectl get service service-a -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -n "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
    echo "Application déployée avec succès!"
    echo "URL d'accès: http://$EXTERNAL_IP:3000"
    echo "Health check: http://$EXTERNAL_IP:3000/health"
else
    echo "L'IP externe est en cours d'attribution..."
    echo "Utilisez 'kubectl get service service-a' pour obtenir l'IP une fois assignée"
fi

echo ""
echo "Déploiement terminé!"
