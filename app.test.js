// app.test.js - Test unitaire de l'API
// Utilise le lanceur de tests integre a Node.js (node --test, dispo depuis Node 18)
const test = require('node:test');
const assert = require('node:assert');
const request = require('supertest');
const app = require('./app');

test('GET /ping doit retourner "pong" avec un code 200', async () => {
  const res = await request(app).get('/ping');
  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.text, 'pong');
});
