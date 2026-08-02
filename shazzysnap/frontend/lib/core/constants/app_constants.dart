class AppConstants {
  AppConstants._();
  static const String appName = 'ShazzySnap';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  static const List<String> authorizedPlatforms = ['pixabay.com','pexels.com','archive.org','commons.wikimedia.org','ccmixter.org','jamendo.com','freemusicarchive.org','freesound.org','mixkit.co','coverr.co','videvo.net'];
  static const int maxConcurrentDownloads = 3;
  static const String defaultDownloadFolder = 'ShazzySnap';
  static const String dbName = 'shazzysnap.db';
  static const int dbVersion = 1;
  static const String tableDownloads = 'downloads';
  static const String keyThemeMode = 'theme_mode';
  static const String keyThemeColor = 'theme_color';
  static const String keyDownloadPath = 'download_path';
  static const String keyAutoUpdate = 'auto_update';
  static const String keyNotifications = 'notifications_enabled';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const int trendingCount = 12;
  static const int pageSize = 20;
}
