import 'dart:async';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/download_entity.dart';
import '../../models/download_model.dart';
import 'database_helper.dart';

abstract class DownloadLocalDataSource {
  Future<void> saveDownload(DownloadModel d);
  Future<void> updateDownload(DownloadModel d);
  Future<void> deleteDownload(String id);
  Future<DownloadModel?> getDownloadById(String id);
  Future<DownloadModel?> getDownloadByTaskId(String taskId);
  Future<List<DownloadModel>> getAllDownloads();
  Future<List<DownloadModel>> getDownloadsByStatus(DownloadStatus s);
  Future<List<DownloadModel>> getCompletedDownloads({int? limit});
  Future<List<DownloadModel>> getFavorites();
  Future<List<DownloadModel>> getHistory({int limit=50});
  Future<void> toggleFavorite(String id);
  Future<void> updateProgress(String taskId, double progress, int downloadedBytes);
  Future<void> updateStatus(String taskId, DownloadStatus status, {String? filePath, String? error});
  Future<void> clearHistory();
  Future<int> getTotalDownloadedSize();
  Stream<List<DownloadModel>> watchAllDownloads();
}

class DownloadLocalDataSourceImpl implements DownloadLocalDataSource {
  final DatabaseHelper _db;
  final _ctrl = StreamController<List<DownloadModel>>.broadcast();
  DownloadLocalDataSourceImpl(this._db);

  Future<void> _notify() async { final all = await getAllDownloads(); if(!_ctrl.isClosed) _ctrl.add(all); }

  @override Future<void> saveDownload(DownloadModel d) async { try { await _db.insert(AppConstants.tableDownloads, d.toDbMap()); await _notify(); } catch(e) { throw StorageFailure('Save failed: $e'); } }
  @override Future<void> updateDownload(DownloadModel d) async { await _db.update(AppConstants.tableDownloads, d.toDbMap(), 'id=?', [d.id]); await _notify(); }
  @override Future<void> deleteDownload(String id) async { await _db.delete(AppConstants.tableDownloads, 'id=?', [id]); await _notify(); }
  @override Future<DownloadModel?> getDownloadById(String id) async { final r = await _db.query(AppConstants.tableDownloads, where:'id=?', whereArgs:[id], limit:1); return r.isEmpty?null:DownloadModel.fromDbMap(r.first); }
  @override Future<DownloadModel?> getDownloadByTaskId(String tid) async { final r = await _db.query(AppConstants.tableDownloads, where:'task_id=?', whereArgs:[tid], limit:1); return r.isEmpty?null:DownloadModel.fromDbMap(r.first); }
  @override Future<List<DownloadModel>> getAllDownloads() async { final r = await _db.query(AppConstants.tableDownloads, orderBy:'created_at DESC'); return r.map(DownloadModel.fromDbMap).toList(); }
  @override Future<List<DownloadModel>> getDownloadsByStatus(DownloadStatus s) async { final r = await _db.query(AppConstants.tableDownloads, where:'status=?', whereArgs:[s.name], orderBy:'created_at DESC'); return r.map(DownloadModel.fromDbMap).toList(); }
  @override Future<List<DownloadModel>> getCompletedDownloads({int? limit}) async { final r = await _db.query(AppConstants.tableDownloads, where:'status=?', whereArgs:[DownloadStatus.completed.name], orderBy:'completed_at DESC', limit:limit); return r.map(DownloadModel.fromDbMap).toList(); }
  @override Future<List<DownloadModel>> getFavorites() async { final r = await _db.query(AppConstants.tableDownloads, where:'is_favorite=1 AND status=?', whereArgs:[DownloadStatus.completed.name], orderBy:'created_at DESC'); return r.map(DownloadModel.fromDbMap).toList(); }
  @override Future<List<DownloadModel>> getHistory({int limit=50}) async { final r = await _db.query(AppConstants.tableDownloads, where:'status IN (?,?,?)', whereArgs:[DownloadStatus.completed.name,DownloadStatus.cancelled.name,DownloadStatus.failed.name], orderBy:'created_at DESC', limit:limit); return r.map(DownloadModel.fromDbMap).toList(); }
  @override Future<void> toggleFavorite(String id) async { final d = await getDownloadById(id); if(d==null) return; await _db.update(AppConstants.tableDownloads, {'is_favorite':d.isFavorite?0:1}, 'id=?', [id]); await _notify(); }
  @override Future<void> updateProgress(String taskId, double progress, int bytes) async { await _db.update(AppConstants.tableDownloads, {'progress':progress,'downloaded_bytes':bytes,'status':DownloadStatus.running.name}, 'task_id=?', [taskId]); await _notify(); }
  @override Future<void> updateStatus(String taskId, DownloadStatus status, {String? filePath, String? error}) async { final data = <String,dynamic>{'status':status.name}; if(filePath!=null) data['file_path']=filePath; if(error!=null) data['error_message']=error; if(status==DownloadStatus.completed){data['completed_at']=DateTime.now().toIso8601String();data['progress']=1.0;} await _db.update(AppConstants.tableDownloads, data, 'task_id=?', [taskId]); await _notify(); }
  @override Future<void> clearHistory() async { await _db.delete(AppConstants.tableDownloads, 'status IN (?,?)', [DownloadStatus.cancelled.name,DownloadStatus.failed.name]); await _notify(); }
  @override Future<int> getTotalDownloadedSize() async { final r = await _db.rawQuery('SELECT SUM(file_size) as total FROM ${AppConstants.tableDownloads} WHERE status=?', [DownloadStatus.completed.name]); return (r.first['total'] as int?)??0; }
  @override Stream<List<DownloadModel>> watchAllDownloads() { getAllDownloads().then((d){if(!_ctrl.isClosed) _ctrl.add(d);}); return _ctrl.stream; }
}
