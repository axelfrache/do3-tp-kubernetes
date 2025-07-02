const express = require('express');
const axios = require('axios');

const app = express();
const PORT = 3000;

app.use(express.json());

app.get('/', async (req, res) => {
  try {
    const response = await axios.get('http://service-b:3000/hello');
    res.json(response.data);
  } catch (error) {
    console.error('Erreur lors de l\'appel au service B:', error.message);
    res.status(500).json({ 
      error: 'Impossible de contacter le service B',
      details: error.message 
    });
  }
});

app.get('/health', async (req, res) => {
  try {
    const response = await axios.get('http://service-b:3000/hello', {
      timeout: 5000
    });
    
    if (response.status === 200) {
      res.status(200).json({ 
        status: 'ok',
        service_b_status: 'healthy',
        timestamp: new Date().toISOString()
      });
    } else {
      res.status(500).json({ 
        status: 'error',
        service_b_status: 'unhealthy',
        details: `Service B returned status ${response.status}`,
        timestamp: new Date().toISOString()
      });
    }
  } catch (error) {
    console.error('Health check failed - Service B unreachable:', error.message);
    res.status(500).json({ 
      status: 'error',
      service_b_status: 'unreachable',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Service A démarré sur le port ${PORT}`);
});
