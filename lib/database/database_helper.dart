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

  Future<Database> get database async{
    if(_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'ContactManagement.db');
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async{
    await db.execute(
      '''
         CREATE TABLE contacts(
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           name TEXT NOT NULL,
           phoneNumber TEXT NOT NULL,
           email TEXT NOT NULL,
           address TEXT NOT NULL,
           isFavourite INTEGER NOT NULL DEFAULT 0
         )
      '''
    );
  }//end method


}