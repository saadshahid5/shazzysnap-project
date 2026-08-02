'use strict';
const express = require('express');
const router = express.Router();
const trendingService = require('../services/trendingService');

router.get('/', async (req, res, next) => {
  try {
    const { q, page = 1, limit = 20 } = req.query;
    if (!q || q.trim().length < 2) {
      return res.status(400).json({ success: false, error: 'Query must be at least 2 characters' });
    }
    const data = await trendingService.search(q.trim(), { page: parseInt(page), limit: parseInt(limit) });
    res.json({ success: true, data, query: q });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
