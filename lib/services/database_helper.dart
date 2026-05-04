import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'students_v2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students(
        id TEXT PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        major TEXT NOT NULL,
        level TEXT NOT NULL,
        subjects TEXT NOT NULL,
        presentDays INTEGER NOT NULL,
        totalDays INTEGER NOT NULL,
        profilePicture TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<List<Student>> getStudents() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students', orderBy: 'lastName ASC');
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<void> insertStudent(Student student) async {
    Database db = await database;
    var map = student.toMap();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['updatedAt'] = DateTime.now().toIso8601String();
    
    await db.insert(
      'students',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateStudent(Student student) async {
    Database db = await database;
    var map = student.toMap();
    map.remove('id');
    map['updatedAt'] = DateTime.now().toIso8601String();

    await db.update(
      'students',
      map,
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<void> deleteStudent(String id) async {
    Database db = await database;
    await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}