'use strict';
require('dotenv').config();
const app = require('./app');
const logger = require('./utils/logger');
const { initDatabase } = require('./database/db');
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';
async function start() {
  try {
    await initDatabase();
    logger.info('Database initialized');
    const server = app.listen(PORT, HOST, () => {
      logger.info(`ShazzySnap API running on http://${HOST}:${PORT}`);
    });
    const shutdown = (signal) => { logger.info(`${signal} received`); server.close(() => process.exit(0)); };
    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));
  } catch (err) {
    logger.error('Failed to start:', err);
    process.exit(1);
  }
}
start();
