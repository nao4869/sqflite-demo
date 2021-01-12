import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_demo/models/todo.dart';
import 'package:sqflite_demo/pages/home_screen.dart';
import 'package:sqflite_demo/providers/database_provider.dart';
import 'package:sqflite_demo/providers/todo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'todo_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE todo(id INTEGER PRIMARY KEY, name TEXT, imagePath TEXT, createdAt TEXT)',
      );
    },
    version: 1,
  );

  Future<List<Todo>> getTodoList() async {
    final db = await database;
    final maps = await db.query('todo', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        name: maps[i]['name'],
        imagePath: maps[i]['imagePath'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  final todoList = await getTodoList();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TodoProvider(
            todoList: todoList,
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
      debugShowCheckedModeBanner: false,
      title: 'SQLite demo',
      home: HomeScreen(),
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
      },
    );
  }
}
