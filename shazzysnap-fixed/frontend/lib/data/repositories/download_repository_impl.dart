import 'package:uuid/uuid.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../../domain/entities/download_entity.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/download_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/local/download_local_datasource.dart';
import '../models/download_model.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadLocalDataSource _local;
  final _uuid = const Uuid();
  DownloadRepositoryImpl(this._local);

  @override Future<DownloadEntity> startDownload({required VideoEntity video, required VideoFormat format, required String savePath}) async {
    final taskId = await FlutterDownloader.enqueue(url:format.downloadUrl,savedDir:savePath,fileName:'${video.title.replaceAll(RegExp(r'[<>:"/\\|?*]'),'_')}.${format.format}',showNotification:true,openFileFromNotification:true);
    if(taskId==null) throw const DownloadFailure('Failed to create download task');
    final d = DownloadModel(id:_uuid.v4(),taskId:taskId,videoId:video.id,title:video.title,url:video.url,downloadUrl:format.downloadUrl,thumbnailUrl:video.thumbnailUrl,quality:format.quality,format:format.format,platform:video.platform,mediaType:format.hasVideo?MediaType.video:MediaType.audio,status:DownloadStatus.queued,progress:0.0,fileSize:format.fileSize,createdAt:DateTime.now(),isFavorite:false,duration:video.duration);
    await _local.saveDownload(d);
    return d;
  }

  @override Future<void> pauseDownload(String id) async { final d=await _local.getDownloadById(id); if(d==null) return; await FlutterDownloader.pause(taskId:d.taskId); await _local.updateStatus(d.taskId,DownloadStatus.paused); }
  @override Future<void> resumeDownload(String id) async { final d=await _local.getDownloadById(id); if(d==null) return; final nid=await FlutterDownloader.resume(taskId:d.taskId); if(nid!=null) await _local.updateDownload(DownloadModel(id:d.id,taskId:nid,videoId:d.videoId,title:d.title,url:d.url,downloadUrl:d.downloadUrl,thumbnailUrl:d.thumbnailUrl,quality:d.quality,format:d.format,platform:d.platform,mediaType:d.mediaType,status:DownloadStatus.running,progress:d.progress,fileSize:d.fileSize,downloadedBytes:d.downloadedBytes,filePath:d.filePath,createdAt:d.createdAt,isFavorite:d.isFavorite,duration:d.duration)); }
  @override Future<void> cancelDownload(String id) async { final d=await _local.getDownloadById(id); if(d==null) return; await FlutterDownloader.cancel(taskId:d.taskId); await _local.updateStatus(d.taskId,DownloadStatus.cancelled); }
  @override Future<void> retryDownload(String id) async { final d=await _local.getDownloadById(id); if(d==null) return; await FlutterDownloader.retry(taskId:d.taskId); }
  @override Future<void> deleteDownload(String id,{bool deleteFile=false}) async { final d=await _local.getDownloadById(id); if(d==null) return; if(deleteFile) await FlutterDownloader.remove(taskId:d.taskId,shouldDeleteContent:true); await _local.deleteDownload(id); }
  @override Stream<List<DownloadEntity>> watchAllDownloads() => _local.watchAllDownloads().cast();
  @override Future<List<DownloadEntity>> getAllDownloads() async => await _local.getAllDownloads();
  @override Future<List<DownloadEntity>> getCompletedDownloads() async => await _local.getCompletedDownloads();
  @override Future<List<DownloadEntity>> getActiveDownloads() async { final q=await _local.getDownloadsByStatus(DownloadStatus.queued); final r=await _local.getDownloadsByStatus(DownloadStatus.running); final p=await _local.getDownloadsByStatus(DownloadStatus.paused); return [...q,...r,...p]; }
  @override Future<List<DownloadEntity>> getFavorites() async => await _local.getFavorites();
  @override Future<List<DownloadEntity>> getHistory({int limit=50}) async => await _local.getHistory(limit:limit);
  @override Future<void> toggleFavorite(String id) async => await _local.toggleFavorite(id);
  @override Future<void> updateProgress(String taskId, double progress, int bytes) async => await _local.updateProgress(taskId,progress,bytes);
  @override Future<void> updateStatus(String taskId, DownloadStatus status, {String? filePath, String? error}) async => await _local.updateStatus(taskId,status,filePath:filePath,error:error);
  @override Future<void> clearHistory() async => await _local.clearHistory();
  @override Future<int> getTotalDownloadedSize() async => await _local.getTotalDownloadedSize();
}
