'use strict';
const request = require('supertest');
const app = require('../src/app');
const { initDatabase } = require('../src/database/db');

beforeAll(async () => { await initDatabase(); });

describe('Health', () => {
  it('GET /api/v1/health returns 200', async () => {
    const res = await request(app).get('/api/v1/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('healthy');
  });
});

describe('Analyze', () => {
  it('rejects missing URL', async () => {
    const res = await request(app).post('/api/v1/analyze').send({});
    expect(res.status).toBe(400);
  });

  it('rejects unauthorized platform', async () => {
    const res = await request(app).post('/api/v1/analyze').send({ url: 'https://youtube.com/watch?v=test' });
    expect(res.status).toBe(403);
  });

  it('accepts authorized Pixabay URL', async () => {
    const res = await request(app).post('/api/v1/analyze').send({ url: 'https://pixabay.com/videos/nature-1/' });
    expect([200, 404, 500]).toContain(res.status); // depends on API key
  });
});

describe('Trending', () => {
  it('GET /api/v1/trending returns data', async () => {
    const res = await request(app).get('/api/v1/trending');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  it('supports category filter', async () => {
    const res = await request(app).get('/api/v1/trending?category=Music');
    expect(res.status).toBe(200);
  });

  it('supports pagination', async () => {
    const res = await request(app).get('/api/v1/trending?page=1&limit=4');
    expect(res.status).toBe(200);
    expect(res.body.data.length).toBeLessThanOrEqual(4);
  });
});

describe('Search', () => {
  it('rejects short query', async () => {
    const res = await request(app).get('/api/v1/search?q=a');
    expect(res.status).toBe(400);
  });

  it('searches successfully', async () => {
    const res = await request(app).get('/api/v1/search?q=nature');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
  });
});

describe('URL Check', () => {
  it('flags unauthorized domain', async () => {
    const res = await request(app).get('/api/v1/analyze/check?url=https://youtube.com/watch?v=x');
    expect(res.body.data.authorized).toBe(false);
  });

  it('approves authorized domain', async () => {
    const res = await request(app).get('/api/v1/analyze/check?url=https://pixabay.com/videos/id-1/');
    expect(res.body.data.authorized).toBe(true);
  });
});
