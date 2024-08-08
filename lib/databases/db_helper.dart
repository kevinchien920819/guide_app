import 'package:mysql1/mysql1.dart';

class DbHelper {
  final String host = '127.0.0.1';
  final int port = 3306;
  final String user = 'root';
  // final String password = ''; // 预设不设定密码
  final String dbName = 'guide_app';

  MySqlConnection? _connection;

  Future<MySqlConnection> get connection async {
    if (_connection != null) {
      return _connection!;
    }
    _connection = await _initDb();
    return _connection!;
  }

  Future<MySqlConnection> _initDb() async {
    try {
      final settings = ConnectionSettings(
        host: host,
        port: port,
        user: user,
        // password: password,
        db: dbName,
      );
      print('Attempting to connect to the database...');
      final conn = await MySqlConnection.connect(settings);
      print('Database connection established.');
      return conn;
    } catch (e) {
      print('Error connecting to the database: $e');
      rethrow;
    }
  }

  Future<void> createUserTable() async {
    try {
      final conn = await connection;
      await conn.query('''
        CREATE TABLE IF NOT EXISTS User (
          email VARCHAR(255) PRIMARY KEY,
          password VARCHAR(255) NOT NULL
        )
      ''');
      print('User table created or already exists.');
    } catch (e) {
      print('Error creating user table: $e');
    }
  }

  Future<void> insertUser(String email, String password) async {
    try {
      final conn = await connection;
      await conn.query(
        'INSERT INTO User (email, password) VALUES (?, ?)',
        [email, password],
      );
      print('User inserted successfully.');
    } catch (e) {
      print('Error inserting user: $e');
    }
  }

  Future<Results> getUser(String email) async {
    try {
      final conn = await connection;
      return await conn.query(
        'SELECT * FROM User WHERE email = ?',
        [email],
      );
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  Future<void> closeDb() async {
    try {
      final conn = await connection;
      await conn.close();
      print('Database connection closed.');
    } catch (e) {
      print('Error closing database connection: $e');
    }
  }
}
