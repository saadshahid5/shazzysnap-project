import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/download_local_datasource.dart';
import '../../data/datasources/remote/video_remote_datasource.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../data/repositories/download_repository_impl.dart';
import '../../domain/repositories/video_repository.dart';
import '../../domain/repositories/download_repository.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((_) => const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true)));
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl:AppConstants.baseUrl,connectTimeout:AppConstants.connectTimeout,receiveTimeout:AppConstants.receiveTimeout,headers:{'Content-Type':'application/json','Accept':'application/json'}));
  dio.interceptors.add(LogInterceptor(requestBody:false,responseBody:false));
  return dio;
});
final databaseHelperProvider = Provider<DatabaseHelper>((_) => DatabaseHelper());
final downloadLocalDataSourceProvider = Provider<DownloadLocalDataSource>((ref) => DownloadLocalDataSourceImpl(ref.watch(databaseHelperProvider)));
final videoRemoteDataSourceProvider = Provider<VideoRemoteDataSource>((ref) => VideoRemoteDataSourceImpl(ref.watch(dioProvider)));
final videoRepositoryProvider = Provider<VideoRepository>((ref) => VideoRepositoryImpl(ref.watch(videoRemoteDataSourceProvider)));
final downloadRepositoryProvider = Provider<DownloadRepository>((ref) => DownloadRepositoryImpl(ref.watch(downloadLocalDataSourceProvider)));

Future<void> setupDependencies() async {
  await SharedPreferences.getInstance();
}
