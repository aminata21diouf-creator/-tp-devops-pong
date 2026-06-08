// server.js - Demarre le serveur HTTP
const app = require('./app');

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Serveur demarre sur http://localhost:${PORT}`);
});
