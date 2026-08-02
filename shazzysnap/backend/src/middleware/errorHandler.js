'use strict';
const logger = require('../utils/logger');

module.exports = (err, req, res, next) => {
  const status = err.status || err.statusCode || 500;
  const message = err.message || 'Internal server error';
  logger.error(`${status} - ${message} - ${req.originalUrl} - ${req.method}`);
  res.status(status).json({ success: false, error: message });
};
