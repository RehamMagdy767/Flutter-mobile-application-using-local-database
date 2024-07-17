import 'package:ass1/JSON/users.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final databaseName = "auth.db";

  String user = '''
  CREATE TABLE users(
   userid INTEGER PRIMARY KEY AUTOINCREMENT,
   userName TEXT,
   userEmail TEXT UNIQUE,
   level TEXT,
   gender TEXT,
   password TEXT,
   image BLOB
  )
''';

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    return openDatabase(path, version: 2, onCreate: (db, version) async {
      await db.execute(user);
      // Add the new column for image data even if the database is newly created
      await db.execute('ALTER TABLE users ADD COLUMN image BLOB');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Add the new column for image data during upgrade
        await db.execute('ALTER TABLE users ADD COLUMN image BLOB');
      }
    });
  }

  Future<bool> authenticate(Users usr) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
        "SELECT * FROM users WHERE userEmail = ? AND password = ?",
        [usr.userEmail, usr.password]);

    return result.isNotEmpty;
  }

  Future<int> createUser(Users usr) async {
    final Database db = await initDB();

    // Check if the email already exists in the database
    var existingUser = await db.query(
      'users',
      where: 'userEmail = ?',
      whereArgs: [usr.userEmail],
    );

    if (existingUser.isNotEmpty) {
      // If user with the same email exists, return an error code
      return -1;
    }

    // Insert the user record if the email is unique
    return await db.insert("users", usr.toMap());
  }

  Future<Users?> getUser(String userName) async {
    final Database db = await initDB();
    var res =
        await db.query("users", where: "userName = ?", whereArgs: [userName]);
    return res.isNotEmpty ? Users.fromMap(res.first) : null;
  }

  Future<String?> getUserNameByEmail(String email) async {
    try {
      final Database db = await initDB();
      var res = await db.query(
        "users",
        columns: ["userName"],
        where: "userEmail = ?",
        whereArgs: [email],
      );
      return res.isNotEmpty ? res.first["userName"] as String? : null;
    } catch (e) {
      print("Error fetching userName by email: $e");
      return null;
    }
  }

  Future<int> updateUser(Users updatedUser) async {
    final Database db = await initDB();
    return await db.update(
      'users',
      updatedUser.toMap(),
      where: 'userEmail = ?',
      whereArgs: [updatedUser.userEmail],
    );
  }
}
