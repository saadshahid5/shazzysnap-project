'use strict';
const express = require('express');
const router = express.Router();
const { isAuthorizedUrl } = require('../utils/platformUtils');

// Proxy download for authorized platforms (handles CORS / redirects)
router.get('/proxy', async (req, res, next) => {
  try {
    const { url } = req.query;
    if (!url) return res.status(400).json({ success: false, error: 'URL required' });
    if (!isAuthorizedUrl(url)) {
      return res.status(403).json({ success: false, error: 'Unauthorized platform' });
    }
    // Stream the file through
    const axios = require('axios');
    const response = await axios.get(url, { responseType: 'stream', timeout: 30000 });
    res.setHeader('Content-Type', response.headers['content-type'] || 'application/octet-stream');
    if (response.headers['content-length']) {
      res.setHeader('Content-Length', response.headers['content-length']);
    }
    res.setHeader('Content-Disposition', 'attachment');
    response.data.pipe(res);
  } catch (err) {
    next(err);
  }
});

// Validate download URL before client starts download
router.post('/validate', (req, res) => {
  const { url } = req.body;
  if (!url) return res.status(400).json({ success: false, error: 'URL required' });
  const valid = isAuthorizedUrl(url);
  res.json({ success: true, data: { valid, url } });
});

module.exports = router;
