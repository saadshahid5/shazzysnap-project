'use strict';
const express = require('express');
const router = express.Router();
const analyzerService = require('../services/analyzerService');
const { isAuthorizedUrl } = require('../utils/platformUtils');

router.post('/', async (req, res, next) => {
  try {
    const { url } = req.body;
    if (!url || typeof url !== 'string') {
      return res.status(400).json({ success: false, error: 'URL is required' });
    }
    if (!isAuthorizedUrl(url)) {
      return res.status(403).json({ success: false, error: 'Platform not authorized for downloading' });
    }
    const data = await analyzerService.analyzeUrl(url.trim());
    res.json({ success: true, data });
  } catch (err) {
    if (err.status) return res.status(err.status).json({ success: false, error: err.message });
    next(err);
  }
});

router.get('/check', (req, res) => {
  const { url } = req.query;
  if (!url) return res.status(400).json({ success: false, error: 'URL required' });
  const authorized = isAuthorizedUrl(url);
  res.json({ success: true, data: { url, authorized } });
});

module.exports = router;
