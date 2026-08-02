import '../entities/video_entity.dart';
import '../repositories/video_repository.dart';
import '../../core/errors/failures.dart';
class AnalyzeUrlUseCase {
  final VideoRepository _repo;
  const AnalyzeUrlUseCase(this._repo);
  Future<VideoEntity> call(String url) async {
    final uri = Uri.tryParse(url);
    if(uri==null||!uri.hasScheme) throw const InvalidUrlFailure('Invalid URL format');
    final ok = await _repo.isUrlAuthorized(url);
    if(!ok) throw const UnauthorizedPlatformFailure('This platform is not authorized. ShazzySnap only supports Pixabay, Pexels, Archive.org, ccMixter, Jamendo, Mixkit, Coverr, Freesound and Wikimedia.');
    return await _repo.analyzeUrl(url);
  }
}
