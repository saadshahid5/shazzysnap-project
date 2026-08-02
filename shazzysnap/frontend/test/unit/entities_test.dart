import 'package:flutter_test/flutter_test.dart';
import 'package:shazzysnap/core/constants/app_constants.dart';
import 'package:shazzysnap/core/errors/failures.dart';
import 'package:shazzysnap/domain/entities/video_entity.dart';
import 'package:shazzysnap/domain/entities/download_entity.dart';

void main() {
  group('AppConstants', () {
    test('authorized platforms list is not empty', () {
      expect(AppConstants.authorizedPlatforms, isNotEmpty);
    });

    test('contains Pixabay', () {
      expect(AppConstants.authorizedPlatforms.contains('pixabay.com'), isTrue);
    });

    test('contains Pexels', () {
      expect(AppConstants.authorizedPlatforms.contains('pexels.com'), isTrue);
    });
  });

  group('VideoFormat', () {
    test('fileSizeFormatted returns KB for small sizes', () {
      const fmt = VideoFormat(
        id: '1', quality: '360p', format: 'mp4',
        mimeType: 'video/mp4', fileSize: 512000,
        hasAudio: true, hasVideo: true, downloadUrl: 'https://example.com/video.mp4',
      );
      expect(fmt.fileSizeFormatted, contains('KB'));
    });

    test('fileSizeFormatted returns MB for medium sizes', () {
      const fmt = VideoFormat(
        id: '2', quality: '720p', format: 'mp4',
        mimeType: 'video/mp4', fileSize: 52428800,
        hasAudio: true, hasVideo: true, downloadUrl: 'https://example.com/video.mp4',
      );
      expect(fmt.fileSizeFormatted, contains('MB'));
    });

    test('displayQuality shows audio only label', () {
      const fmt = VideoFormat(
        id: '3', quality: 'Audio', format: 'mp3',
        mimeType: 'audio/mpeg',
        hasAudio: true, hasVideo: false, downloadUrl: 'https://example.com/audio.mp3',
      );
      expect(fmt.displayQuality, contains('Audio'));
    });
  });

  group('DownloadEntity', () {
    test('isActive is true when running', () {
      final d = DownloadEntity(
        id: '1', taskId: 'task1', videoId: 'v1',
        title: 'Test', url: 'https://pixabay.com/1',
        downloadUrl: 'https://cdn.pixabay.com/1.mp4',
        quality: '720p', format: 'mp4', platform: 'Pixabay',
        mediaType: MediaType.video, status: DownloadStatus.running,
        progress: 0.5, createdAt: DateTime.now(), isFavorite: false,
      );
      expect(d.isActive, isTrue);
    });

    test('isActive is false when completed', () {
      final d = DownloadEntity(
        id: '2', taskId: 'task2', videoId: 'v2',
        title: 'Done', url: 'https://pixabay.com/2',
        downloadUrl: 'https://cdn.pixabay.com/2.mp4',
        quality: '1080p', format: 'mp4', platform: 'Pixabay',
        mediaType: MediaType.video, status: DownloadStatus.completed,
        progress: 1.0, createdAt: DateTime.now(), isFavorite: true,
      );
      expect(d.isActive, isFalse);
    });

    test('statusLabel shows correct text', () {
      final d = DownloadEntity(
        id: '3', taskId: 't3', videoId: 'v3',
        title: 'Test', url: 'https://pixabay.com/3',
        downloadUrl: 'https://cdn.pixabay.com/3.mp4',
        quality: '480p', format: 'mp4', platform: 'Pixabay',
        mediaType: MediaType.video, status: DownloadStatus.failed,
        progress: 0.3, createdAt: DateTime.now(), isFavorite: false,
      );
      expect(d.statusLabel, 'Failed');
    });
  });

  group('Failures', () {
    test('NetworkFailure has message', () {
      const f = NetworkFailure('No connection');
      expect(f.message, 'No connection');
      expect(f.toString(), 'No connection');
    });

    test('UnauthorizedPlatformFailure is a Failure', () {
      const f = UnauthorizedPlatformFailure();
      expect(f, isA<Failure>());
    });
  });
}
