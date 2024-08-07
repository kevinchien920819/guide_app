import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

class DbHelper {
  static Database? _db;
  // Database name and version
  static const String dbName = 'test.db';
  static const int _version = 1;

  // Table name
  static const String tableUser = 'User';
  // Column names
  static const String mailbox = 'email';
  static const String password = 'password';

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    var theDb =
        await openDatabase(path, version: _version, onCreate: _onCreate);
    return theDb;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableUser (
      $mailbox TEXT PRIMARY KEY,
      $password TEXT NOT NULL
    )
    ''');
  }

  Future<void> closeDb() async {
    var dbClient = await db;
    await dbClient.close();
  }
}
