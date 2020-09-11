import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_demo/models/dog.dart';

class DataBaseProvider with ChangeNotifier {
  DataBaseProvider({
    this.database,
  });

  Future<Database> database;

  Future<Database> getDatabaseInfo() {
    return database;
  }

  Future<void> insertDog(Dog dog) async {
    final Database db = await database;
    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Dog>> dogs() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dogs');
    return List.generate(maps.length, (i) {
      return Dog(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }

  Future<void> updateDog(Dog dog) async {
    final db = await database;
    await db.update(
      'dogs',
      dog.toMap(),
      where: "id = ?",
      whereArgs: [dog.id],
    );
  }

  Future<void> deleteDog(int id) async {
    final db = await database;
    await db.delete(
      'dogs',
      where: "id = ?",
      whereArgs: [id],
    );
  }

}