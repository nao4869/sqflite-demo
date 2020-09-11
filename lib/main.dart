import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_demo/models/dog.dart';
import 'package:sqflite_demo/pages/pages.dart';
import 'package:sqflite_demo/providers/database_provider.dart';
import 'package:sqflite_demo/providers/dogs_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'doggie_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
      );
    },
    version: 1,
  );

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

  var fido = Dog(
    id: 0,
    name: 'Fido',
    age: 35,
  );

  await insertDog(fido);
  print(await dogs());

  fido = Dog(
    id: fido.id,
    name: fido.name,
    age: fido.age + 7,
  );
  final dogList = await dogs();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DogsProvider(
            dogs: dogList,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DataBaseProvider(
            database: database,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sqflite demo',
      home: HomeScreen(),
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
      },
    );
  }
}
