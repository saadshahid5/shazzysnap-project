import '../entities/video_entity.dart';
import '../entities/trending_entity.dart';
abstract class VideoRepository {
  Future<VideoEntity> analyzeUrl(String url);
  Future<List<TrendingEntity>> getTrending({int page=1,String? category});
  Future<List<TrendingEntity>> search(String query,{int page=1});
  Future<bool> isUrlAuthorized(String url);
  Future<String> getPlatformFromUrl(String url);
}
