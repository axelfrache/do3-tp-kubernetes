# Configurer les secrets GitHub pour l'Action Docker

Pour que le workflow GitHub Actions puisse pousser des images vers Docker Hub, vous devez configurer deux secrets dans votre dépôt GitHub :

1. Allez dans votre dépôt GitHub
2. Cliquez sur "Settings" > "Secrets and variables" > "Actions"
3. Cliquez sur "New repository secret"
4. Ajoutez les secrets suivants :
   - `DOCKERHUB_USERNAME` : votre nom d'utilisateur Docker Hub (axelfrache)
   - `DOCKERHUB_TOKEN` : votre token d'accès personnel Docker Hub (pas votre mot de passe)

## Comment obtenir un token Docker Hub

1. Connectez-vous à [Docker Hub](https://hub.docker.com)
2. Cliquez sur votre nom d'utilisateur puis "Account Settings"
3. Allez dans l'onglet "Security"
4. Cliquez sur "New Access Token"
5. Donnez un nom à votre token (ex: "GitHub Actions") et sélectionnez les permissions adéquates
6. Copiez le token généré et utilisez-le comme valeur pour `DOCKERHUB_TOKEN` dans GitHub
