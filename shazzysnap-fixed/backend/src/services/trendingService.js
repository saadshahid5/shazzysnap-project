'use strict';
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');
const { cacheGet, cacheSet } = require('../database/db');
const logger = require('../utils/logger');

class TrendingService {
  async getTrending({ page = 1, limit = 12, category } = {}) {
    const cacheKey = `trending:${page}:${limit}:${category || 'all'}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const results = await Promise.allSettled([
      this._fetchPixabay(category),
      this._fetchPexels(category),
      this._fetchJamendo(category),
    ]);

    let items = [];
    for (const r of results) {
      if (r.status === 'fulfilled') items = items.concat(r.value);
    }

    // If all APIs fail, use curated mock
    if (items.length === 0) items = this._getMockTrending();

    // Paginate
    const start = (page - 1) * limit;
    const paginated = items.slice(start, start + limit);

    cacheSet(cacheKey, paginated, 1800);
    return paginated;
  }

  async search(query, { page = 1, limit = 20 } = {}) {
    const cacheKey = `search:${query}:${page}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const results = await Promise.allSettled([
      this._searchPixabay(query),
      this._searchPexels(query),
    ]);

    let items = [];
    for (const r of results) {
      if (r.status === 'fulfilled') items = items.concat(r.value);
    }

    if (items.length === 0) {
      items = this._getMockTrending().filter(i =>
        i.title.toLowerCase().includes(query.toLowerCase())
      );
    }

    const start = (page - 1) * limit;
    const paginated = items.slice(start, start + limit);
    cacheSet(cacheKey, paginated, 600);
    return paginated;
  }

  async _fetchPixabay(category) {
    const key = process.env.PIXABAY_API_KEY;
    if (!key) return [];
    const params = { key, per_page: 12, video_type: 'film' };
    if (category && category !== 'All') params.category = category.toLowerCase();
    const { data } = await axios.get('https://pixabay.com/api/videos/', { params, timeout: 8000 });
    return (data.hits || []).map(v => ({
      id: String(v.id),
      title: `Pixabay Video ${v.id}`,
      thumbnail_url: `https://i.vimeocdn.com/video/${v.picture_id}_640x360.jpg`,
      source_url: `https://pixabay.com/videos/id-${v.id}/`,
      platform: 'Pixabay',
      author: v.user,
      view_count: v.views,
      duration_seconds: v.duration,
      category: category || 'General',
      published_at: new Date().toISOString(),
      is_downloadable: true,
      license: 'Pixabay License (Free)',
    }));
  }

  async _fetchPexels(category) {
    const key = process.env.PEXELS_API_KEY;
    if (!key) return [];
    const query = category && category !== 'All' ? category : 'nature';
    const { data } = await axios.get('https://api.pexels.com/videos/search', {
      headers: { Authorization: key },
      params: { query, per_page: 12 },
      timeout: 8000,
    });
    return (data.videos || []).map(v => ({
      id: String(v.id),
      title: v.url.split('/').slice(-2, -1)[0]?.replace(/-/g, ' ') || 'Pexels Video',
      thumbnail_url: v.video_pictures?.[0]?.picture || '',
      source_url: v.url,
      platform: 'Pexels',
      author: v.user?.name,
      view_count: null,
      duration_seconds: v.duration,
      category: category || 'General',
      published_at: new Date().toISOString(),
      is_downloadable: true,
      license: 'Pexels License (Free)',
    }));
  }

  async _fetchJamendo(category) {
    const clientId = process.env.JAMENDO_CLIENT_ID;
    if (!clientId) return [];
    const { data } = await axios.get('https://api.jamendo.com/v3.0/tracks/', {
      params: { client_id: clientId, format: 'json', limit: 12, order: 'popularity_total' },
      timeout: 8000,
    });
    return (data.results || []).map(t => ({
      id: String(t.id),
      title: t.name,
      thumbnail_url: t.image,
      source_url: t.shareurl,
      platform: 'Jamendo',
      author: t.artist_name,
      view_count: t.stats?.listened,
      duration_seconds: t.duration,
      category: 'Music',
      published_at: t.releasedate || new Date().toISOString(),
      is_downloadable: true,
      license: 'Creative Commons',
    }));
  }

  async _searchPixabay(query) {
    const key = process.env.PIXABAY_API_KEY;
    if (!key) return [];
    const { data } = await axios.get('https://pixabay.com/api/videos/', {
      params: { key, q: query, per_page: 10 },
      timeout: 8000,
    });
    return (data.hits || []).map(v => ({
      id: String(v.id),
      title: `${query} - Pixabay Video ${v.id}`,
      thumbnail_url: `https://i.vimeocdn.com/video/${v.picture_id}_640x360.jpg`,
      source_url: `https://pixabay.com/videos/id-${v.id}/`,
      platform: 'Pixabay',
      author: v.user,
      view_count: v.views,
      duration_seconds: v.duration,
      category: 'Search',
      published_at: new Date().toISOString(),
      is_downloadable: true,
      license: 'Pixabay License (Free)',
    }));
  }

  async _searchPexels(query) {
    const key = process.env.PEXELS_API_KEY;
    if (!key) return [];
    const { data } = await axios.get('https://api.pexels.com/videos/search', {
      headers: { Authorization: key },
      params: { query, per_page: 10 },
      timeout: 8000,
    });
    return (data.videos || []).map(v => ({
      id: String(v.id),
      title: query + ' - Pexels Video',
      thumbnail_url: v.video_pictures?.[0]?.picture || '',
      source_url: v.url,
      platform: 'Pexels',
      author: v.user?.name,
      view_count: null,
      duration_seconds: v.duration,
      category: 'Search',
      published_at: new Date().toISOString(),
      is_downloadable: true,
      license: 'Pexels License (Free)',
    }));
  }

  _getMockTrending() {
    return [
      { id: 'm1', title: 'Beautiful Nature Timelapse - Free Stock', thumbnail_url: 'https://images.pexels.com/photos/417074/pexels-photo-417074.jpeg?w=640', source_url: 'https://pixabay.com/videos/nature-1/', platform: 'Pixabay', author: 'NatureFilms', view_count: 125000, duration_seconds: 754, category: 'Nature', published_at: new Date().toISOString(), is_downloadable: true, license: 'Pixabay License' },
      { id: 'm2', title: 'City Night Time-lapse 4K - CC0', thumbnail_url: 'https://images.pexels.com/photos/1707820/pexels-photo-1707820.jpeg?w=640', source_url: 'https://pixabay.com/videos/city-2/', platform: 'Pixabay', author: 'UrbanLens', view_count: 89000, duration_seconds: 225, category: 'Travel', published_at: new Date().toISOString(), is_downloadable: true, license: 'Pixabay License' },
      { id: 'm3', title: 'Relaxing Ocean Waves Ambient', thumbnail_url: 'https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?w=640', source_url: 'https://freemusicarchive.org/music/ocean', platform: 'Free Music Archive', author: 'AmbientSounds', view_count: 234000, duration_seconds: 2700, category: 'Music', published_at: new Date().toISOString(), is_downloadable: true, license: 'CC BY 4.0' },
      { id: 'm4', title: 'Abstract Motion Graphics Pack', thumbnail_url: 'https://images.pexels.com/photos/3075993/pexels-photo-3075993.jpeg?w=640', source_url: 'https://mixkit.co/free-stock-video/abstract-1/', platform: 'Mixkit', author: 'MotionDesign', view_count: 67000, duration_seconds: 30, category: 'Design', published_at: new Date().toISOString(), is_downloadable: true, license: 'Mixkit License' },
      { id: 'm5', title: 'Epic Orchestral Score - CC', thumbnail_url: 'https://images.pexels.com/photos/164745/pexels-photo-164745.jpeg?w=640', source_url: 'https://ccmixter.org/files/epic-1', platform: 'ccMixter', author: 'OrchestraPro', view_count: 156000, duration_seconds: 252, category: 'Music', published_at: new Date().toISOString(), is_downloadable: true, license: 'CC BY 3.0' },
      { id: 'm6', title: 'Mountain Drone Footage 4K', thumbnail_url: 'https://images.pexels.com/photos/417173/pexels-photo-417173.jpeg?w=640', source_url: 'https://coverr.co/videos/mountains-1', platform: 'Coverr', author: 'AerialVision', view_count: 198000, duration_seconds: 388, category: 'Travel', published_at: new Date().toISOString(), is_downloadable: true, license: 'Coverr License' },
      { id: 'm7', title: 'Underwater Ocean Life Documentary', thumbnail_url: 'https://images.pexels.com/photos/932638/pexels-photo-932638.jpeg?w=640', source_url: 'https://archive.org/details/ocean-life', platform: 'Archive.org', author: 'OceanDocs', view_count: 310000, duration_seconds: 1800, category: 'Nature', published_at: new Date().toISOString(), is_downloadable: true, license: 'Public Domain' },
      { id: 'm8', title: 'Lo-fi Hip Hop Beats to Study', thumbnail_url: 'https://images.pexels.com/photos/1587927/pexels-photo-1587927.jpeg?w=640', source_url: 'https://jamendo.com/track/lofi-1', platform: 'Jamendo', author: 'LoFiStudio', view_count: 445000, duration_seconds: 3600, category: 'Music', published_at: new Date().toISOString(), is_downloadable: true, license: 'CC BY-NC 4.0' },
    ];
  }
}

module.exports = new TrendingService();
