enum DownloadStatus { queued, running, paused, completed, failed, cancelled }
enum MediaType { video, audio }
class DownloadEntity {
  final String id, taskId, videoId, title, url, downloadUrl;
  final String? thumbnailUrl, filePath, errorMessage;
  final String quality, format, platform;
  final MediaType mediaType;
  final DownloadStatus status;
  final double progress;
  final int? fileSize, downloadedBytes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isFavorite;
  final Duration? duration;
  const DownloadEntity({required this.id,required this.taskId,required this.videoId,required this.title,required this.url,required this.downloadUrl,this.thumbnailUrl,required this.quality,required this.format,required this.platform,required this.mediaType,required this.status,required this.progress,this.fileSize,this.downloadedBytes,this.filePath,this.errorMessage,required this.createdAt,this.completedAt,required this.isFavorite,this.duration});
  bool get isActive => status==DownloadStatus.running||status==DownloadStatus.queued;
  String get fileSizeFormatted { if(fileSize==null) return 'Unknown'; final b=fileSize!; if(b<1024*1024) return '${(b/1024).toStringAsFixed(1)} KB'; if(b<1024*1024*1024) return '${(b/(1024*1024)).toStringAsFixed(1)} MB'; return '${(b/(1024*1024*1024)).toStringAsFixed(2)} GB'; }
  String get statusLabel { switch(status) { case DownloadStatus.queued: return 'Queued'; case DownloadStatus.running: return 'Downloading ${(progress*100).toStringAsFixed(0)}%'; case DownloadStatus.paused: return 'Paused'; case DownloadStatus.completed: return 'Completed'; case DownloadStatus.failed: return 'Failed'; case DownloadStatus.cancelled: return 'Cancelled'; } }
  DownloadEntity copyWith({String? id,String? taskId,String? videoId,String? title,String? url,String? downloadUrl,String? thumbnailUrl,String? quality,String? format,String? platform,MediaType? mediaType,DownloadStatus? status,double? progress,int? fileSize,int? downloadedBytes,String? filePath,String? errorMessage,DateTime? createdAt,DateTime? completedAt,bool? isFavorite,Duration? duration}) => DownloadEntity(id:id??this.id,taskId:taskId??this.taskId,videoId:videoId??this.videoId,title:title??this.title,url:url??this.url,downloadUrl:downloadUrl??this.downloadUrl,thumbnailUrl:thumbnailUrl??this.thumbnailUrl,quality:quality??this.quality,format:format??this.format,platform:platform??this.platform,mediaType:mediaType??this.mediaType,status:status??this.status,progress:progress??this.progress,fileSize:fileSize??this.fileSize,downloadedBytes:downloadedBytes??this.downloadedBytes,filePath:filePath??this.filePath,errorMessage:errorMessage??this.errorMessage,createdAt:createdAt??this.createdAt,completedAt:completedAt??this.completedAt,isFavorite:isFavorite??this.isFavorite,duration:duration??this.duration);
}
