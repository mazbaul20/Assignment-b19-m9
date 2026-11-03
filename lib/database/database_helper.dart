import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/contact_model.dart';

class DatabaseHelper {
  //singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  //database variable
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'ContactManagement.db');
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
         CREATE TABLE contacts(
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           name TEXT NOT NULL,
           phoneNumber TEXT NOT NULL,
           email TEXT NOT NULL,
           address TEXT NOT NULL,
           isFavourite INTEGER NOT NULL DEFAULT 0
         )
      ''');
  } //end method

  // Insert contacts
  Future<int> insertContact(ContactModel contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  } //end method

  // all contacts
  Future<List<ContactModel>> getAllContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');

    return maps.map((map) => ContactModel.fromMap(map)).toList();
  } //end method

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  } //end method

  Future<int> updateContact(ContactModel contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  } // end method

  Future<int> updateFavoriteStatus(int id, bool isFavourite) async {
    final db = await database;
    return await db.update(
      'contacts',
      {'isFavourite': isFavourite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  } // end method
}
