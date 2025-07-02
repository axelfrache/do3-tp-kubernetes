const express = require('express');

const app = express();
const PORT = 3000;

app.use(express.json());

app.get('/hello', (req, res) => {
  res.json({ message: 'Bonjour du service B' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Service B démarré sur le port ${PORT}`);
});
