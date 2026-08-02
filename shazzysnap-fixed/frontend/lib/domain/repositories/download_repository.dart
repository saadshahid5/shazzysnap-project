import '../entities/download_entity.dart';
import '../entities/video_entity.dart';
abstract class DownloadRepository {
  Future<DownloadEntity> startDownload({required VideoEntity video,required VideoFormat format,required String savePath});
  Future<void> pauseDownload(String id);
  Future<void> resumeDownload(String id);
  Future<void> cancelDownload(String id);
  Future<void> retryDownload(String id);
  Future<void> deleteDownload(String id,{bool deleteFile=false});
  Stream<List<DownloadEntity>> watchAllDownloads();
  Future<List<DownloadEntity>> getAllDownloads();
  Future<List<DownloadEntity>> getCompletedDownloads();
  Future<List<DownloadEntity>> getActiveDownloads();
  Future<List<DownloadEntity>> getFavorites();
  Future<List<DownloadEntity>> getHistory({int limit=50});
  Future<void> toggleFavorite(String id);
  Future<void> updateProgress(String taskId,double progress,int downloadedBytes);
  Future<void> updateStatus(String taskId,DownloadStatus status,{String? filePath,String? error});
  Future<void> clearHistory();
  Future<int> getTotalDownloadedSize();
}
