'use strict';
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');
const { cacheGet, cacheSet } = require('../database/db');
const logger = require('../utils/logger');
const { getPlatformFromUrl, isAuthorizedUrl } = require('../utils/platformUtils');

class AnalyzerService {
  async analyzeUrl(url) {
    let parsedUrl;
    try { parsedUrl = new URL(url); } catch { throw { status: 400, message: 'Invalid URL format' }; }
    if (!isAuthorizedUrl(url)) throw { status: 403, message: 'Platform not authorized. ShazzySnap only supports: Pixabay, Pexels, Archive.org, ccMixter, Jamendo, Mixkit, Coverr, Freesound, Wikimedia Commons.' };
    const cacheKey = `analyze:${url}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;
    const platform = getPlatformFromUrl(url);
    logger.info(`Analyzing ${platform} URL: ${url}`);
    let result;
    switch (platform.toLowerCase()) {
      case 'pixabay': result = await this._analyzePixabay(url, parsedUrl); break;
      case 'pexels': result = await this._analyzePexels(url, parsedUrl); break;
      case 'archive': result = await this._analyzeArchive(url, parsedUrl); break;
      case 'ccmixter': result = await this._analyzeCcMixter(url, parsedUrl); break;
      case 'jamendo': result = await this._analyzeJamendo(url, parsedUrl); break;
      case 'wikimedia': case 'commons': result = await this._analyzeWikimedia(url, parsedUrl); break;
      default: result = this._mockVideoResult(url, platform, 'Free License');
    }
    cacheSet(cacheKey, result, 3600);
    return result;
  }

  async _analyzePixabay(url, parsedUrl) {
    const apiKey = process.env.PIXABAY_API_KEY;
    if (!apiKey) return this._mockVideoResult(url, 'Pixabay', 'Pixabay License (Free)');
    const match = parsedUrl.pathname.match(/-(\d+)\/?$/);
    const videoId = match ? match[1] : null;
    if (!videoId) throw { status: 400, message: 'Cannot extract Pixabay video ID from URL' };
    const { data } = await axios.get('https://pixabay.com/api/videos/', { params: { key: apiKey, id: videoId }, timeout: 10000 });
    const video = data.hits?.[0];
    if (!video) throw { status: 404, message: 'Video not found on Pixabay' };
    const formats = [];
    const qualityMap = { large: '1080p', medium: '720p', small: '480p', tiny: '240p' };
    for (const [k, q] of Object.entries(qualityMap)) {
      if (video.videos[k]?.url) {
        formats.push({ id: uuidv4(), quality: q, format: 'mp4', mime_type: 'video/mp4', file_size: video.videos[k].size || null, bitrate: null, codec: 'h264', has_audio: true, has_video: true, download_url: video.videos[k].url });
      }
    }
    return { id: String(video.id), url, title: `Pixabay Video ${video.id}`, thumbnail_url: video.picture_id ? `https://i.vimeocdn.com/video/${video.picture_id}_640x360.jpg` : null, duration_seconds: video.duration, platform: 'Pixabay', author: video.user, formats, fetched_at: new Date().toISOString(), is_authorized: true };
  }

  async _analyzePexels(url, parsedUrl) {
    if (!process.env.PEXELS_API_KEY) return this._mockVideoResult(url, 'Pexels', 'Pexels License (Free)');
    return this._mockVideoResult(url, 'Pexels', 'Pexels License (Free)');
  }

  async _analyzeArchive(url, parsedUrl) {
    const identifier = parsedUrl.pathname.split('/').filter(Boolean)[1];
    if (!identifier) throw { status: 400, message: 'Invalid Archive.org URL' };
    try {
      const { data } = await axios.get(`https://archive.org/metadata/${identifier}`, { timeout: 15000 });
      const formats = [];
      const supportedExts = ['mp4','ogv','webm','mp3','ogg','flac'];
      for (const file of data.files || []) {
        const ext = file.name?.split('.').pop()?.toLowerCase();
        if (!supportedExts.includes(ext)) continue;
        const isVideo = ['mp4','ogv','webm'].includes(ext);
        formats.push({ id: uuidv4(), quality: isVideo ? '720p' : 'Original', format: ext, mime_type: isVideo ? `video/${ext}` : `audio/${ext}`, file_size: file.size ? parseInt(file.size) : null, bitrate: null, codec: null, has_audio: true, has_video: isVideo, download_url: `https://archive.org/download/${identifier}/${encodeURIComponent(file.name)}` });
      }
      if (!formats.length) throw { status: 404, message: 'No downloadable files found' };
      return { id: identifier, url, title: data.metadata?.title || identifier, thumbnail_url: `https://archive.org/services/img/${identifier}`, duration_seconds: null, platform: 'Archive.org', author: data.metadata?.creator || null, formats, fetched_at: new Date().toISOString(), is_authorized: true };
    } catch (e) { if (e.status) throw e; return this._mockVideoResult(url, 'Archive.org', 'Public Domain'); }
  }

  async _analyzeCcMixter(url, parsedUrl) { return this._mockAudioResult(url, 'ccMixter', 'Creative Commons'); }
  async _analyzeJamendo(url, parsedUrl) {
    if (!process.env.JAMENDO_CLIENT_ID) return this._mockAudioResult(url, 'Jamendo', 'Creative Commons');
    return this._mockAudioResult(url, 'Jamendo', 'Creative Commons');
  }
  async _analyzeWikimedia(url, parsedUrl) { return this._mockVideoResult(url, 'Wikimedia Commons', 'Creative Commons'); }

  _mockVideoResult(url, platform, license) {
    const qualities = ['1080p','720p','480p','360p'];
    const sizes = [524288000, 209715200, 104857600, 52428800];
    return {
      id: uuidv4(), url, title: `${platform} Video - Free Download`,
      thumbnail_url: 'https://images.pexels.com/photos/417074/pexels-photo-417074.jpeg',
      duration_seconds: 120, platform, author: `${platform} Creator`,
      formats: qualities.map((q, i) => ({ id: uuidv4(), quality: q, format: 'mp4', mime_type: 'video/mp4', file_size: sizes[i], bitrate: [8000000,4000000,2000000,1000000][i], codec: 'h264', has_audio: true, has_video: true, download_url: `${url}?q=${q.replace('p','')}` })),
      fetched_at: new Date().toISOString(), is_authorized: true,
    };
  }

  _mockAudioResult(url, platform, license) {
    return {
      id: uuidv4(), url, title: `${platform} Audio Track`,
      thumbnail_url: null, duration_seconds: 180, platform, author: `${platform} Artist`,
      formats: [
        { id: uuidv4(), quality: '320kbps', format: 'mp3', mime_type: 'audio/mpeg', file_size: 7864320, bitrate: 320000, codec: 'mp3', has_audio: true, has_video: false, download_url: url },
        { id: uuidv4(), quality: '128kbps', format: 'mp3', mime_type: 'audio/mpeg', file_size: 3145728, bitrate: 128000, codec: 'mp3', has_audio: true, has_video: false, download_url: url },
      ],
      fetched_at: new Date().toISOString(), is_authorized: true,
    };
  }
}

module.exports = new AnalyzerService();
