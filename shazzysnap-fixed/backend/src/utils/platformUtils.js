'use strict';

const AUTHORIZED_PLATFORMS = [
  { name: 'Pixabay', domain: 'pixabay.com' },
  { name: 'Pexels', domain: 'pexels.com' },
  { name: 'Archive', domain: 'archive.org' },
  { name: 'ccMixter', domain: 'ccmixter.org' },
  { name: 'Jamendo', domain: 'jamendo.com' },
  { name: 'FreeMusicArchive', domain: 'freemusicarchive.org' },
  { name: 'Mixkit', domain: 'mixkit.co' },
  { name: 'Coverr', domain: 'coverr.co' },
  { name: 'Videvo', domain: 'videvo.net' },
  { name: 'Freesound', domain: 'freesound.org' },
  { name: 'Wikimedia', domain: 'commons.wikimedia.org' },
];

function isAuthorizedUrl(url) {
  try {
    const { hostname } = new URL(url);
    const host = hostname.replace(/^www\./, '');
    return AUTHORIZED_PLATFORMS.some(p => host === p.domain || host.endsWith('.' + p.domain));
  } catch { return false; }
}

function getPlatformFromUrl(url) {
  try {
    const { hostname } = new URL(url);
    const host = hostname.replace(/^www\./, '');
    const match = AUTHORIZED_PLATFORMS.find(p => host === p.domain || host.endsWith('.' + p.domain));
    return match ? match.name : host.split('.')[0];
  } catch { return 'Unknown'; }
}

module.exports = { AUTHORIZED_PLATFORMS, isAuthorizedUrl, getPlatformFromUrl };
