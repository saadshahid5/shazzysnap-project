class VideoEntity {
  final String id;
  final String url;
  final String title;
  final String? thumbnailUrl;
  final Duration? duration;
  final String platform;
  final String? author;
  final List<VideoFormat> formats;
  final DateTime fetchedAt;
  final bool isAuthorized;
  const VideoEntity({required this.id,required this.url,required this.title,this.thumbnailUrl,this.duration,required this.platform,this.author,required this.formats,required this.fetchedAt,required this.isAuthorized});
}
class VideoFormat {
  final String id;
  final String quality;
  final String format;
  final String mimeType;
  final int? fileSize;
  final int? bitrate;
  final String? codec;
  final bool hasAudio;
  final bool hasVideo;
  final String downloadUrl;
  const VideoFormat({required this.id,required this.quality,required this.format,required this.mimeType,this.fileSize,this.bitrate,this.codec,required this.hasAudio,required this.hasVideo,required this.downloadUrl});
  String get displayQuality { if(hasVideo&&hasAudio) return '$quality ($format)'; if(hasVideo&&!hasAudio) return '$quality (video only)'; if(!hasVideo&&hasAudio) return 'Audio ($format)'; return quality; }
  String get fileSizeFormatted { if(fileSize==null) return 'Unknown'; final b=fileSize!; if(b<1024*1024) return '${(b/1024).toStringAsFixed(1)} KB'; if(b<1024*1024*1024) return '${(b/(1024*1024)).toStringAsFixed(1)} MB'; return '${(b/(1024*1024*1024)).toStringAsFixed(2)} GB'; }
}
