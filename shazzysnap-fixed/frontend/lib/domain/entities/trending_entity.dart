class TrendingEntity {
  final String id, title, thumbnailUrl, sourceUrl, platform, category, license;
  final String? description, author;
  final int? viewCount;
  final Duration? duration;
  final DateTime publishedAt;
  final bool isDownloadable;
  const TrendingEntity({required this.id,required this.title,this.description,required this.thumbnailUrl,required this.sourceUrl,required this.platform,this.author,this.viewCount,this.duration,required this.category,required this.publishedAt,required this.isDownloadable,required this.license});
  String get durationFormatted { if(duration==null) return ''; final d=duration!; final h=d.inHours; final m=d.inMinutes.remainder(60); final s=d.inSeconds.remainder(60); if(h>0) return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}'; return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}'; }
  String get viewCountFormatted { if(viewCount==null) return ''; if(viewCount!>=1000000) return '${(viewCount!/1000000).toStringAsFixed(1)}M views'; if(viewCount!>=1000) return '${(viewCount!/1000).toStringAsFixed(1)}K views'; return '$viewCount views'; }
}
