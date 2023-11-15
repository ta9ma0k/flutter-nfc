import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class _SqliteConnector {
  static const dbName = 'spender.db';
  static const version = 1;
  _SqliteConnector._();
  static final _SqliteConnector _connection = _SqliteConnector._();
  factory _SqliteConnector.getConnection() => _connection;
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDb();

  Future<Database> _initDb() async {
    return openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: _onCreate,
      version: version,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS cards(id TEXT PRIMARY KEY, owner TEXT)');
  }
}

typedef FromJson<T> = T Function(Map<String, dynamic> json);

abstract class SqliteEntity {
  Map<String, dynamic> toJson();
  static late FromJson fromJson;
}

class SqliteDao<T extends SqliteEntity> {
  final _database = _SqliteConnector.getConnection().database;
  final String tableName;
  final FromJson<T> fromJson;
  SqliteDao(this.tableName, this.fromJson);

  Future<int> create(T entity) async {
    final db = await _database;
    return db.insert(tableName, entity.toJson());
  }

  Future<T?> readById(String id) async {
    final db = await _database;
    return db.query(tableName, where: 'id = ?', whereArgs: [id]).then(
        (value) => value.length == 1 ? fromJson(value.first) : null);
  }

  Future<List<T>> readAll() async {
    final db = await _database;
    return db
        .query(tableName)
        .then((value) => value.map((e) => fromJson(e)).toList());
  }

  Future<int> delete(String id) async {
    final db = await _database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
