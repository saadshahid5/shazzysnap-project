import '../../domain/entities/video_entity.dart';
import '../../domain/entities/trending_entity.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/remote/video_remote_datasource.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource _remote;
  const VideoRepositoryImpl(this._remote);
  @override Future<VideoEntity> analyzeUrl(String url) async => await _remote.analyzeUrl(url);
  @override Future<List<TrendingEntity>> getTrending({int page=1,String? category}) async => await _remote.getTrending(page:page,category:category);
  @override Future<List<TrendingEntity>> search(String query,{int page=1}) async => await _remote.search(query,page:page);
  @override Future<bool> isUrlAuthorized(String url) async => await _remote.isUrlAuthorized(url);
  @override Future<String> getPlatformFromUrl(String url) async { try { final uri=Uri.parse(url); final h=uri.host.replaceFirst('www.','').split('.'); return h.length>=2?h[h.length-2]:h[0]; } catch(_) { return 'Unknown'; } }
}
