import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static const String _encryptionKey = 'my16bytefixedkey';
  static final _storage = const FlutterSecureStorage();

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE users(
        userId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        username TEXT UNIQUE NOT NULL,
        full_name TEXT,
        password TEXT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);

    await database.execute("""CREATE TABLE paman(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        userId INTEGER NOT NULL,
        appName TEXT,
        username TEXT,
        password TEXT
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'paman.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String appName, int userId, String username, String password) async {
    final db = await SQLHelper.db();

    final data = {
      'userId': userId,
      'appName': appName,
      'username': username,
      'password': password
    };
    final id = await db.insert('paman', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems(int id) async {
    final db = await SQLHelper.db();
    return db.query('paman', where: "id = ?", whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('paman', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(int id, String appName, String username, String password) async {
    final db = await SQLHelper.db();

    final data = {
      'appName': appName,
      'username': username,
      'password': password,
      'createdAt': DateTime.now().toString()
    };

    final result = await db.update('paman', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("paman", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> deleteDatabase() async {
    String path = await sql.getDatabasesPath();
    await sql.deleteDatabase('$path/paman.db');
  }

  static Future<int> createUser(String username, String fullName, String password) async {
    final db = await SQLHelper.db();
    final encryptedPassword = await encryptPassword(password);
    final data = {
      'username': username,
      'full_name': fullName,
      'password': encryptedPassword
    };
    final id = await db.insert('users', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<Map<String, dynamic>> getUserByUsername(String username) async {
    final db = await SQLHelper.db();
    final result = await db.query('users', where: 'username = ?', whereArgs: [username], limit: 1);
    return result.isNotEmpty ? result.first : {};
  }

  static Future<Map<String, dynamic>> getUserById(int id) async {
    final db = await SQLHelper.db();
    final result = await db.query('users', where: 'userId = ?', whereArgs: [id], limit: 1);
    return result.isNotEmpty ? result.first : {};
  }

  static Future<void> _getIV() async {
    String? iv64 = await _storage.read(key: 'encryptionIV');
    if (iv64 == null) {
      iv64 = IV.fromLength(16).base64;
      await _storage.write(key: 'encryptionIV', value: iv64);
    }
  }

  static Future<IV> _retrieveIV() async {
    String? iv64 = await _storage.read(key: 'encryptionIV');
    return IV.fromBase64(iv64!);
  }

  static Future<String> encryptPassword(String password) async {
    final key = Key.fromUtf8(_encryptionKey);
    await _getIV();
    final iv = await _retrieveIV();
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  static Future<String> decryptPassword(String encryptedPassword) async {
    final key = Key.fromUtf8(_encryptionKey);
    final iv = await _retrieveIV();
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedPassword, iv: iv);
    return decrypted;
  }
}