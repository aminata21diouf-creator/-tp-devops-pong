// app.js - Definition de l'API Express
// On separe la definition de l'app (ici) et le demarrage du serveur (server.js)
// pour pouvoir tester l'app sans ouvrir un vrai port reseau.

const express = require('express');
const app = express();

// Route de test : GET /ping  ->  renvoie "pong"
app.get('/ping', (req, res) => {
  res.send('pong');
});

// Petite page d'accueil
app.get('/', (req, res) => {
  res.send('API DevOps UCAD - essayez /ping');
});

module.exports = app;
