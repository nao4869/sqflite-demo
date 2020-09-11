import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    //final databaseNotifier = Provider.of<DataBaseProvider>(context);
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
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
