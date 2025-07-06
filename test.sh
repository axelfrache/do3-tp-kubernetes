#!/bin/bash

# Script de test pour l'application microservices
# Ce script teste toutes les fonctionnalités de l'application

set -e

# Variables
EXTERNAL_IP=$(kubectl get service service-a -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
SERVICE_URL="http://$EXTERNAL_IP:3000"

echo "Test de l'application microservices"
echo "URL de l'application : $SERVICE_URL"
echo ""

# Test 1: Vérifier que le service A est accessible
echo "Test de connectivité du Service A..."
if curl -s -f "$SERVICE_URL/" > /dev/null; then
    echo "Service A accessible"
else
    echo "Service A inaccessible"
    exit 1
fi

# Test 2: Tester la route principale (Service A appelle Service B)
echo ""
echo "Test de la route principale (Service A -> Service B)..."
RESPONSE=$(curl -s "$SERVICE_URL/")
EXPECTED='{"message":"Bonjour du service B"}'

if [ "$RESPONSE" = "$EXPECTED" ]; then
    echo "Communication Service A -> Service B OK"
    echo "   Réponse : $RESPONSE"
else
    echo "Communication Service A -> Service B ERREUR"
    echo "   Attendu : $EXPECTED"
    echo "   Reçu    : $RESPONSE"
    exit 1
fi

# Test 3: Tester le health check (Service A teste Service B)
echo ""
echo "Test du health check (Service A teste Service B)..."
HEALTH_RESPONSE=$(curl -s "$SERVICE_URL/health")
echo "   Réponse health check : $HEALTH_RESPONSE"

if echo "$HEALTH_RESPONSE" | grep -q '"status":"ok"' && echo "$HEALTH_RESPONSE" | grep -q '"service_b_status":"healthy"'; then
    echo "Health check OK - Service B est healthy"
else
    echo "Health check ERREUR - Service B pourrait avoir un problème"
    exit 1
fi

# Test 4: Vérifier les codes de statut HTTP
echo ""
echo "Test des codes de statut HTTP..."
STATUS_ROOT=$(curl -s -o /dev/null -w "%{http_code}" "$SERVICE_URL/")
STATUS_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" "$SERVICE_URL/health")

if [ "$STATUS_ROOT" = "200" ] && [ "$STATUS_HEALTH" = "200" ]; then
    echo "Codes de statut HTTP corrects (200)"
else
    echo "Codes de statut HTTP incorrects"
    echo "   Route / : $STATUS_ROOT (attendu: 200)"
    echo "   Route /health : $STATUS_HEALTH (attendu: 200)"
    exit 1
fi

echo ""
echo "Tous les tests sont passés avec succès !"
echo ""
echo "Résumé des endpoints :"
echo "   • Service A (principal) : $SERVICE_URL/"
echo "   • Health check          : $SERVICE_URL/health"
echo ""
echo "Architecture :"
echo "   Service A (LoadBalancer) -> Service B (ClusterIP)"
echo "   Service A vérifie la santé du Service B via /health"
