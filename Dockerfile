# Image de base : Node.js 18 version "slim" (legere)
FROM node:18-slim

# Dossier de travail dans le conteneur
WORKDIR /app

# On copie d'abord les fichiers de dependances pour profiter du cache Docker
COPY package*.json ./

# Installation des dependances de production uniquement
RUN npm install --omit=dev

# On copie le reste du code de l'application
COPY . .

# L'application ecoute sur le port 3000
EXPOSE 3000

# Commande de demarrage du conteneur
CMD ["npm", "start"]
