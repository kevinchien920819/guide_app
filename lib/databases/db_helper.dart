import 'package:mysql1/mysql1.dart';

class DbHelper {
  // MySQL 数据库配置
  final String host = 'your_mysql_host';
  final int port = 3306; // MySQL 默认端口
  final String user = 'your_mysql_user';
  final String password = 'your_mysql_password';
  final String dbName = 'your_database_name';

  MySqlConnection? _connection;

  // 获取 MySQL 连接
  Future<MySqlConnection> get connection async {
    if (_connection != null) {
      return _connection!;
    }
    _connection = await _initDb();
    return _connection!;
  }

  Future<MySqlConnection> _initDb() async {
    final settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: dbName,
    );
    return await MySqlConnection.connect(settings);
  }

  // 创建用户表
  Future<void> createUserTable() async {
    final conn = await connection;
    await conn.query('''
    CREATE TABLE IF NOT EXISTS User (
      email VARCHAR(255) PRIMARY KEY,
      password VARCHAR(255) NOT NULL
    )
    ''');
  }

  // 插入用户
  Future<void> insertUser(String email, String password) async {
    final conn = await connection;
    await conn.query(
      'INSERT INTO User (email, password) VALUES (?, ?)',
      [email, password],
    );
  }

  // 获取用户
  Future<Results> getUser(String email) async {
    final conn = await connection;
    return await conn.query(
      'SELECT * FROM User WHERE email = ?',
      [email],
    );
  }

  // 关闭数据库连接
  Future<void> closeDb() async {
    final conn = await connection;
    await conn.close();
  }
}
