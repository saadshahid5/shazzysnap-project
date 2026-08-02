# ShazzySnap 📥

A premium Android application for downloading **authorized and freely licensed** media content from platforms that explicitly permit downloading.

---

## ✨ Features

| Feature | Details |
|---|---|
| 🔍 URL Analyzer | Paste any URL from authorized platforms — get title, thumbnail, duration, formats |
| 📥 Download Manager | Pause, resume, retry, cancel, queue, background download |
| 🎬 Format Selection | Choose from 240p → 1440p, MP4/WebM/MP3/M4A |
| 📚 Library | Videos, Audio, Favorites, History tabs |
| 🌙 Dark/Light Mode | Full Material 3 theming |
| 🎨 Theme Colors | 8 accent color presets |
| 🔔 Notifications | Live download progress notifications |
| 🔒 Security | Encrypted settings, minimal permissions |
| ⚡ Performance | Lazy loading, caching, shimmer skeletons |

---

## 🏗️ Architecture

```
Clean Architecture + MVVM + Repository Pattern

Presentation  →  Domain  →  Data
(Flutter UI)    (Entities,   (Remote API,
(ViewModels)     UseCases,    SQLite,
(Providers)      Repos)       Models)
```

---

## 🔐 Authorized Platforms Only

ShazzySnap **only** supports downloading from platforms where it is explicitly permitted:

- **Pixabay** — Pixabay License (free commercial use)
- **Pexels** — Pexels License (free commercial use)
- **Archive.org** — Public Domain / Various open licenses
- **ccMixter** — Creative Commons music
- **Jamendo** — Creative Commons music
- **Free Music Archive** — Creative Commons
- **Mixkit** — Free stock video
- **Coverr** — Free stock video
- **Freesound** — Creative Commons audio
- **Wikimedia Commons** — Free media

---

## 🚀 Quick Start

### Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

### Backend (Node.js)

```bash
cd backend
cp .env.example .env
# Add your API keys to .env
npm install
npm run dev
```

### With Docker

```bash
docker-compose up -d
```

---

## 🔑 API Keys (Optional)

The app works without API keys (shows curated content), but for live data:

| Platform | Get Key |
|---|---|
| Pixabay | https://pixabay.com/api/docs/ |
| Pexels | https://www.pexels.com/api/ |
| Jamendo | https://developer.jamendo.com/ |
| Freesound | https://freesound.org/apiv2/ |

Add to `backend/.env`:
```
PIXABAY_API_KEY=your_key
PEXELS_API_KEY=your_key
JAMENDO_CLIENT_ID=your_id
FREESOUND_API_KEY=your_key
```

---

## 📁 Project Structure

```
shazzysnap/
├── frontend/                     # Flutter app
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/        # App constants & strings
│   │   │   ├── di/               # Dependency injection
│   │   │   ├── errors/           # Failure types
│   │   │   ├── router/           # GoRouter navigation
│   │   │   └── theme/            # Material 3 theme
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── local/        # SQLite + Flutter Downloader
│   │   │   │   └── remote/       # Dio HTTP client
│   │   │   ├── models/           # JSON serializable models
│   │   │   └── repositories/     # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/         # Core business objects
│   │   │   ├── repositories/     # Abstract repository interfaces
│   │   │   └── usecases/         # Business logic
│   │   └── presentation/
│   │       ├── providers/        # Riverpod global state
│   │       ├── screens/          # Full screens
│   │       ├── viewmodels/       # Screen-level state notifiers
│   │       └── widgets/          # Reusable UI components
│   ├── android/                  # Android-specific config
│   ├── assets/                   # Images, fonts, animations
│   └── test/                     # Unit + widget tests
│
└── backend/                      # Node.js API
    ├── src/
    │   ├── app.js                # Express setup
    │   ├── server.js             # Entry point
    │   ├── database/             # SQLite + cache
    │   ├── middleware/           # Auth, error, logging
    │   ├── routes/               # API endpoints
    │   ├── services/             # Business logic
    │   └── utils/                # Helpers
    └── test/                     # Jest API tests
```

---

## 🧪 Testing

### Flutter
```bash
cd frontend
flutter test
```

### Backend
```bash
cd backend
npm test
npm run test -- --coverage
```

---

## 🛡️ Security

- **Platform allowlist** enforced on both frontend and backend
- **Encrypted local settings** via `flutter_secure_storage`
- **Minimal permissions** — only requests what's needed
- **Runtime permission handling** for Android 13+
- **Rate limiting** on all API endpoints
- **Input validation** on all routes

---

## 📱 Screenshots

| Splash | Home | Download | Library | Settings |
|---|---|---|---|---|
| Dark gradient logo | Trending + search | URL analysis + formats | Videos/Audio/Favorites | Theme + download config |

---

## 🔧 Tech Stack

| Layer | Technology |
|---|---|
| Frontend UI | Flutter 3.x + Material 3 |
| State Management | Riverpod 2 |
| Navigation | GoRouter |
| Network | Dio |
| Local DB | SQLite (sqflite) |
| Downloads | flutter_downloader |
| Auth | Firebase Auth |
| Backend | Node.js + Express |
| Backend DB | SQLite (better-sqlite3) |
| Animations | flutter_animate + Lottie |
| Images | cached_network_image |

---

## 📄 License

MIT License — ShazzySnap itself is open source. Content downloaded through the app is subject to the license of the originating platform.
