'use strict';
const express = require('express');
const router = express.Router();
const trendingService = require('../services/trendingService');

router.get('/', async (req, res, next) => {
  try {
    const { page = 1, limit = 12, category } = req.query;
    const data = await trendingService.getTrending({
      page: parseInt(page),
      limit: parseInt(limit),
      category,
    });
    res.json({ success: true, data, page: parseInt(page), limit: parseInt(limit) });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
