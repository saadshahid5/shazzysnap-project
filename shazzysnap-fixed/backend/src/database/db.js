'use strict';
const Database = require('better-sqlite3');
const path = require('path');
const fs = require('fs');
const logger = require('../utils/logger');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, '../../data/shazzysnap.db');
let db;

function getDb() {
  if (!db) throw new Error('Database not initialized');
  return db;
}

async function initDatabase() {
  const dir = path.dirname(DB_PATH);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  db = new Database(DB_PATH);
  db.pragma('journal_mode = WAL');
  db.pragma('synchronous = NORMAL');
  db.pragma('foreign_keys = ON');
  createTables();
  seedData();
  logger.info(`Database ready at ${DB_PATH}`);
  return db;
}

function createTables() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS platforms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      domain TEXT NOT NULL UNIQUE,
      api_endpoint TEXT,
      api_key_env TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      license TEXT NOT NULL DEFAULT 'Various',
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );
    CREATE TABLE IF NOT EXISTS cache (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      expires_at TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );
    CREATE INDEX IF NOT EXISTS idx_cache_expires ON cache(expires_at);
  `);
}

function seedData() {
  const existing = db.prepare('SELECT COUNT(*) as count FROM platforms').get();
  if (existing.count > 0) return;
  const insert = db.prepare('INSERT OR IGNORE INTO platforms (name, domain, license) VALUES (?, ?, ?)');
  const platforms = [
    ['Pixabay','pixabay.com','Pixabay License'],
    ['Pexels','pexels.com','Pexels License'],
    ['Archive.org','archive.org','Public Domain / Various'],
    ['ccMixter','ccmixter.org','Creative Commons'],
    ['Jamendo','jamendo.com','Creative Commons'],
    ['Mixkit','mixkit.co','Mixkit License'],
    ['Coverr','coverr.co','Coverr License'],
    ['Freesound','freesound.org','Creative Commons'],
    ['Wikimedia Commons','commons.wikimedia.org','Creative Commons'],
  ];
  const insertMany = db.transaction((items) => { for (const i of items) insert.run(...i); });
  insertMany(platforms);
  logger.info('Platform seed data inserted');
}

function cacheSet(key, value, ttlSeconds = 3600) {
  const expiresAt = new Date(Date.now() + ttlSeconds * 1000).toISOString();
  db.prepare('INSERT OR REPLACE INTO cache (key, value, expires_at) VALUES (?, ?, ?)').run(key, JSON.stringify(value), expiresAt);
}

function cacheGet(key) {
  const row = db.prepare("SELECT value FROM cache WHERE key = ? AND expires_at > datetime('now')").get(key);
  return row ? JSON.parse(row.value) : null;
}

function cacheDelete(key) { db.prepare('DELETE FROM cache WHERE key = ?').run(key); }
function cacheClear() { db.prepare("DELETE FROM cache WHERE expires_at <= datetime('now')").run(); }

module.exports = { getDb, initDatabase, cacheSet, cacheGet, cacheDelete, cacheClear };
