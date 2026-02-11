import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:islamic_library_flutter/data/models/hadith_model.dart';

class HadithService {
  static final HadithService _instance = HadithService._internal();
  factory HadithService() => _instance;
  HadithService._internal();

  Database? _database;
  Completer<Database>? _dbOpenCompleter;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // If initialization is already in progress, return the future
    if (_dbOpenCompleter != null) {
      return _dbOpenCompleter!.future;
    }

    // Start initialization
    _dbOpenCompleter = Completer<Database>();

    try {
      final db = await _initDatabase();
      _database = db;
      _dbOpenCompleter!.complete(db);
      return db;
    } catch (e) {
      // If initialization fails, reset the completer so we can try again
      _dbOpenCompleter!.completeError(e);
      _dbOpenCompleter = null;
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hadith_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE hadiths(
            id TEXT PRIMARY KEY,
            number INTEGER,
            arab TEXT,
            book_id TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE books(
            id TEXT PRIMARY KEY,
            name TEXT,
            available INTEGER
          )
        ''');
      },
    );
  }

  Future<List<HadithBook>> getLocalBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');

    // Always include Nawawi's Forty from asset if not in DB
    final List<HadithBook> books = maps
        .map((json) => HadithBook.fromJson(json))
        .toList();

    if (!books.any((b) => b.id == 'nawawi')) {
      books.insert(
        0,
        HadithBook(id: 'nawawi', name: 'الأربعون النووية', available: 40),
      );
    }

    return books;
  }

  Future<List<HadithModel>> getHadiths(
    String bookId, {
    int start = 1,
    int end = 20,
  }) async {
    if (bookId == 'nawawi') {
      return _getNawawiHadiths(start, end);
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'hadiths',
      where: 'book_id = ? AND number BETWEEN ? AND ?',
      whereArgs: [bookId, start, end],
    );

    return maps.map((json) => HadithModel.fromJson(json)).toList();
  }

  Future<List<HadithModel>> _getNawawiHadiths(int start, int end) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/hadith/nawawi_forty.json',
      );
      final List<dynamic> data = json.decode(response);
      final List<HadithModel> all = data
          .map((json) => HadithModel.fromJson(json))
          .toList();

      // Filter by range (1-indexed)
      return all.where((h) => h.number! >= start && h.number! <= end).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveHadiths(String bookId, List<HadithModel> hadiths) async {
    final db = await database;
    final batch = db.batch();
    for (var h in hadiths) {
      batch.insert('hadiths', {
        'id': '${h.id}_$bookId',
        'number': h.number,
        'arab': h.arab,
        'book_id': bookId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<void> saveBook(HadithBook book) async {
    final db = await database;
    await db.insert(
      'books',
      book.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
