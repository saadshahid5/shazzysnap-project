import '../../domain/entities/video_entity.dart';
class VideoModel extends VideoEntity {
  const VideoModel({required super.id,required super.url,required super.title,super.thumbnailUrl,super.duration,required super.platform,super.author,required super.formats,required super.fetchedAt,required super.isAuthorized});
  factory VideoModel.fromJson(Map<String,dynamic> j) => VideoModel(id:j['id'] as String,url:j['url'] as String,title:j['title'] as String,thumbnailUrl:j['thumbnail_url'] as String?,duration:j['duration_seconds']!=null?Duration(seconds:(j['duration_seconds'] as num).toInt()):null,platform:j['platform'] as String,author:j['author'] as String?,formats:(j['formats'] as List<dynamic>?)?.map((f)=>VideoFormatModel.fromJson(f as Map<String,dynamic>)).toList()??[],fetchedAt:DateTime.parse(j['fetched_at'] as String),isAuthorized:j['is_authorized'] as bool?? false);
  Map<String,dynamic> toJson()=>{'id':id,'url':url,'title':title,'thumbnail_url':thumbnailUrl,'duration_seconds':duration?.inSeconds,'platform':platform,'author':author,'formats':(formats as List<VideoFormatModel>).map((f)=>f.toJson()).toList(),'fetched_at':fetchedAt.toIso8601String(),'is_authorized':isAuthorized};
}
class VideoFormatModel extends VideoFormat {
  const VideoFormatModel({required super.id,required super.quality,required super.format,required super.mimeType,super.fileSize,super.bitrate,super.codec,required super.hasAudio,required super.hasVideo,required super.downloadUrl});
  factory VideoFormatModel.fromJson(Map<String,dynamic> j) => VideoFormatModel(id:j['id'] as String,quality:j['quality'] as String,format:j['format'] as String,mimeType:j['mime_type'] as String,fileSize:j['file_size'] as int?,bitrate:j['bitrate'] as int?,codec:j['codec'] as String?,hasAudio:j['has_audio'] as bool??true,hasVideo:j['has_video'] as bool??true,downloadUrl:j['download_url'] as String);
  Map<String,dynamic> toJson()=>{'id':id,'quality':quality,'format':format,'mime_type':mimeType,'file_size':fileSize,'bitrate':bitrate,'codec':codec,'has_audio':hasAudio,'has_video':hasVideo,'download_url':downloadUrl};
}
