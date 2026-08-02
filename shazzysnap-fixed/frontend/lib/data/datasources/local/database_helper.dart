import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/constants/app_constants.dart';

class DatabaseHelper {
  static Database? _db;
  Future<Database> get database async { _db ??= await _init(); return _db!; }
  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return openDatabase(path, version: AppConstants.dbVersion, onCreate: _create);
  }
  Future<void> _create(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS ${AppConstants.tableDownloads}(id TEXT PRIMARY KEY,task_id TEXT,video_id TEXT NOT NULL,title TEXT NOT NULL,url TEXT NOT NULL,download_url TEXT NOT NULL,thumbnail_url TEXT,quality TEXT NOT NULL,format TEXT NOT NULL,platform TEXT NOT NULL,media_type TEXT NOT NULL DEFAULT 'video',status TEXT NOT NULL DEFAULT 'queued',progress REAL NOT NULL DEFAULT 0.0,file_size INTEGER,downloaded_bytes INTEGER,file_path TEXT,error_message TEXT,created_at TEXT NOT NULL,completed_at TEXT,is_favorite INTEGER NOT NULL DEFAULT 0,duration_seconds INTEGER)''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_status ON ${AppConstants.tableDownloads}(status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_created ON ${AppConstants.tableDownloads}(created_at DESC)');
  }
  Future<int> insert(String table, Map<String,dynamic> data) async => (await database).insert(table,data,conflictAlgorithm:ConflictAlgorithm.replace);
  Future<int> update(String table, Map<String,dynamic> data, String where, List<dynamic> args) async => (await database).update(table,data,where:where,whereArgs:args);
  Future<int> delete(String table, String where, List<dynamic> args) async => (await database).delete(table,where:where,whereArgs:args);
  Future<List<Map<String,dynamic>>> query(String table,{String? where,List<dynamic>? whereArgs,String? orderBy,int? limit}) async => (await database).query(table,where:where,whereArgs:whereArgs,orderBy:orderBy,limit:limit);
  Future<List<Map<String,dynamic>>> rawQuery(String sql,[List<dynamic>? args]) async => (await database).rawQuery(sql,args);
}
