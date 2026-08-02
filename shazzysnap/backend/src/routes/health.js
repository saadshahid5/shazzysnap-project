'use strict';
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({
    success: true,
    status: 'healthy',
    app: 'ShazzySnap API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  });
});

module.exports = router;
