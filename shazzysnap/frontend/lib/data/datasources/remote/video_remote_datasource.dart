import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../models/video_model.dart';
import '../../models/trending_model.dart';

abstract class VideoRemoteDataSource {
  Future<VideoModel> analyzeUrl(String url);
  Future<List<TrendingModel>> getTrending({int page=1,String? category});
  Future<List<TrendingModel>> search(String query,{int page=1});
  Future<bool> isUrlAuthorized(String url);
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Dio _dio;
  VideoRemoteDataSourceImpl(this._dio);

  @override Future<VideoModel> analyzeUrl(String url) async {
    try {
      final r = await _dio.post('/analyze', data:{'url':url});
      if(r.statusCode==200) return VideoModel.fromJson(r.data['data'] as Map<String,dynamic>);
      throw ServerFailure(r.data['error'] as String??'Error', r.statusCode);
    } on DioException catch(e) { throw _handle(e); }
  }

  @override Future<List<TrendingModel>> getTrending({int page=1,String? category}) async {
    try {
      final r = await _dio.get('/trending', queryParameters:{'page':page,'limit':AppConstants.trendingCount,if(category!=null)'category':category});
      if(r.statusCode==200) return (r.data['data'] as List).map((i)=>TrendingModel.fromJson(i as Map<String,dynamic>)).toList();
      throw ServerFailure('Failed', r.statusCode);
    } on DioException catch(e) { throw _handle(e); }
  }

  @override Future<List<TrendingModel>> search(String query,{int page=1}) async {
    try {
      final r = await _dio.get('/search', queryParameters:{'q':query,'page':page});
      if(r.statusCode==200) return (r.data['data'] as List).map((i)=>TrendingModel.fromJson(i as Map<String,dynamic>)).toList();
      throw ServerFailure('Search failed', r.statusCode);
    } on DioException catch(e) { throw _handle(e); }
  }

  @override Future<bool> isUrlAuthorized(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if(uri==null) return false;
      final host = uri.host.replaceFirst('www.','');
      return AppConstants.authorizedPlatforms.any((p)=>host==p||host.endsWith('.$p'));
    } catch(_) { return false; }
  }

  Failure _handle(DioException e) {
    switch(e.type) {
      case DioExceptionType.connectionTimeout: case DioExceptionType.receiveTimeout: return const TimeoutFailure();
      case DioExceptionType.connectionError: return const NetworkFailure('No internet connection');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final msg = e.response?.data?['error'] as String?;
        if(code==403) return UnauthorizedPlatformFailure(msg??'Not authorized');
        if(code==400) return InvalidUrlFailure(msg??'Invalid URL');
        return ServerFailure(msg??'Server error', code);
      default: return NetworkFailure(e.message??'Network error');
    }
  }
}
