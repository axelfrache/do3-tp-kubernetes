# Application Web Minimale - Services A et B

Cette application démontre une architecture microservices simple avec deux services Node.js/Express qui communiquent entre eux via Kubernetes.

## Architecture

- **Service A** : Client qui appelle le Service B
- **Service B** : Serveur qui fournit l'endpoint `/hello`

## Services

### Service A (Port 3000)
- `GET /` : Appelle le Service B et retourne sa réponse
- `GET /health` : Status de santé (vérifie que Service B est disponible)

### Service B (Port 3000)
- `GET /hello` : Retourne `{ "message": "Bonjour du service B" }`
- `GET /health` : Status de santé

## Développement Local

### Service A
```bash
cd service-a
npm install
npm start
```

### Service B
```bash
cd service-b
npm install
npm start
```

## Docker

### Construire les images
```bash
# Service A
cd service-a
docker build -t axelfrache/service-a:latest .

# Service B
cd service-b
docker build -t axelfrache/service-b:latest .
```

### Exécuter avec Docker
```bash
# Service B (doit être démarré en premier)
docker run -p 3000:3000 --name service-b service-b

# Service A (dans un autre terminal)
docker run -p 3001:3000 --name service-a --link service-b service-a
```

## Kubernetes

Les services sont conçus pour fonctionner dans Kubernetes où :
- Le Service A appelle le Service B via `http://service-b:3000/hello`
- La résolution DNS Kubernetes permet cette communication inter-services

## Déploiement et test

Le projet inclut un script qui automatise le processus de déploiement :
```bash
./deploy.sh
```

Une fois le déploiement terminé, un script est fourni pour tester l'application :
```bash
./test.sh
```

Une fois les services déployés :
- Service B direct : `curl http://service-b:3000/hello`
- Via Service A : `curl http://service-a:3000/`
- Health checks : `curl http://service-a:3000/health` et `curl http://service-b:3000/health`
