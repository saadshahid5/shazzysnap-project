import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/download_entity.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/download_repository.dart';
import '../../domain/repositories/video_repository.dart';
import '../../domain/usecases/analyze_url_usecase.dart';

abstract class DownloadState {}
class DownloadInitial extends DownloadState {}
class DownloadAnalyzing extends DownloadState {}
class DownloadAnalyzed extends DownloadState { final VideoEntity video; final VideoFormat? selectedFormat; DownloadAnalyzed(this.video,{this.selectedFormat}); }
class DownloadInProgress extends DownloadState { final VideoEntity video; final VideoFormat selectedFormat; final DownloadEntity download; DownloadInProgress(this.video,this.selectedFormat,this.download); }
class DownloadError extends DownloadState { final String message; DownloadError(this.message); }

class DownloadViewModel extends StateNotifier<DownloadState> {
  final VideoRepository _videoRepo;
  final DownloadRepository _downloadRepo;
  late final AnalyzeUrlUseCase _analyzeUrl;
  DownloadViewModel(this._videoRepo,this._downloadRepo):super(DownloadInitial()){ _analyzeUrl=AnalyzeUrlUseCase(_videoRepo); }

  Future<void> analyzeUrl(String url) async {
    state=DownloadAnalyzing();
    try { final v=await _analyzeUrl(url.trim()); state=DownloadAnalyzed(v); }
    on Failure catch(e) { state=DownloadError(e.message); }
    catch(e) { state=DownloadError('Failed to analyze: $e'); }
  }

  void selectFormat(VideoFormat f) { final c=state; if(c is DownloadAnalyzed) state=DownloadAnalyzed(c.video,selectedFormat:f); }

  Future<void> startDownload() async {
    final c=state;
    if(c is! DownloadAnalyzed||c.selectedFormat==null) return;
    try {
      if(!await _checkPermission()) { state=DownloadError('Storage permission required'); return; }
      final path=await _getPath();
      final d=await _downloadRepo.startDownload(video:c.video,format:c.selectedFormat!,savePath:path);
      state=DownloadInProgress(c.video,c.selectedFormat!,d);
    } on Failure catch(e) { state=DownloadError(e.message); }
    catch(e) { state=DownloadError('Download failed: $e'); }
  }

  Future<bool> _checkPermission() async {
    if(Platform.isAndroid) {
      final s=await Permission.storage.request();
      if(!s.isGranted) { await Permission.manageExternalStorage.request(); }
      return s.isGranted||await Permission.videos.status.isGranted;
    }
    return true;
  }

  Future<String> _getPath() async {
    final p=await SharedPreferences.getInstance();
    final custom=p.getString(AppConstants.keyDownloadPath);
    if(custom!=null&&await Directory(custom).exists()) return custom;
    final ext=await getExternalStorageDirectory();
    if(ext!=null) { final d=Directory('${ext.path}/${AppConstants.defaultDownloadFolder}'); if(!await d.exists()) await d.create(recursive:true); return d.path; }
    final app=await getApplicationDocumentsDirectory();
    final d=Directory('${app.path}/${AppConstants.defaultDownloadFolder}');
    if(!await d.exists()) await d.create(recursive:true);
    return d.path;
  }

  void reset() => state=DownloadInitial();
}

final downloadViewModelProvider = StateNotifierProvider.autoDispose<DownloadViewModel,DownloadState>((ref) => DownloadViewModel(ref.watch(videoRepositoryProvider),ref.watch(downloadRepositoryProvider)));
