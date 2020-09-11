import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_demo/models/dog.dart';
import 'package:sqflite_demo/providers/database_provider.dart';
import 'package:sqflite_demo/providers/dogs_provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final databaseNotifier = Provider.of<DataBaseProvider>(context);
    final dbInstance = databaseNotifier.getDatabaseInfo();
    final dogsNotifier = Provider.of<DogsProvider>(context);
    final dogs = dogsNotifier.dogs;
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: dogs.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              dense: true,
              leading: Text(
                dogs[index].id.toString(),
              ),
              title: Text(
                dogs[index].name + ' ' + dogs[index].age.toString() + '歳',
              ),
              trailing: Icon(Icons.more_vert),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      children: <Widget>[
                        SimpleDialogOption(
                          onPressed: () {
                            // データベース更新
                            databaseNotifier.deleteDog(dogs[index].id);
                            dogsNotifier.deleteDog(dogs[index].id);
                            Navigator.pop(context);
                          },
                          child: Center(child: Text('削除')),
                        ),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(context),
                          child: Center(child: Text('編集')),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final dog = Dog(
            id: dogs.length,
            name: 'dog name',
            age: 10,
          );

          // データベースへ保存 - 挿入
          databaseNotifier.insertDog(dog);
          dogsNotifier.addDog(dog);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
