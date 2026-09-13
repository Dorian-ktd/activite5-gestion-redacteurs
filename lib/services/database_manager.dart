import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.js_util) 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../modele/redacteur.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  factory DatabaseManager() => _instance;
  DatabaseManager._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // ---- CAS 2 : WINDOWS / LINUX / MACOS ----
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // ---- CHEMIN DE LA BASE ----
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'redacteurs.db');

    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE redacteurs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE
      )
    ''');
    debugPrint('✅ Table "redacteurs" créée avec succès !');
  }

  Future<List<Redacteur>> getAllRedacteurs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'redacteurs',
      orderBy: 'nom ASC, prenom ASC',
    );
    return List.generate(maps.length, (i) {
      return Redacteur.fromMap(maps[i]);
    });
  }

  Future<int> insertRedacteur(Redacteur redacteur) async {
    final db = await database;
    final map = redacteur.toMap()..remove('id');
    return await db.insert('redacteurs', map);
  }

  Future<int> updateRedacteur(Redacteur redacteur) async {
    final db = await database;
    final map = redacteur.toMap()..remove('id');
    return await db.update(
      'redacteurs',
      map,
      where: 'id = ?',
      whereArgs: [redacteur.id],
    );
  }

  Future<int> deleteRedacteur(int id) async {
    final db = await database;
    return await db.delete('redacteurs', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> emailExiste(String email, {int? excludeId}) async {
    final db = await database;
    String sql = 'SELECT COUNT(*) FROM redacteurs WHERE email = ?';
    final args = <Object?>[email];
    if (excludeId != null) {
      sql += ' AND id != ?';
      args.add(excludeId);
    }
    final result = await db.rawQuery(sql, args);
    return Sqflite.firstIntValue(result)! > 0;
  }

  /// Vérifie que l'email a un format valide (version permissive)
  Future<bool> emailValide(String email) async {
    final regex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
    );
    return regex.hasMatch(email.trim());
  }

  /// Vide tous les rédacteurs de la base
  Future<int> deleteAllRedacteurs() async {
    final db = await database;
    return await db.delete('redacteurs');
  }
}
