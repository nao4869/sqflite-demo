import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_demo/Utility/utility.dart';
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
    final size = MediaQuery.of(context).size;
    final databaseNotifier = Provider.of<DataBaseProvider>(context);
    final dogsNotifier = Provider.of<DogsProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: dogsNotifier.dogsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              //dense: true,
              leading: Text(
                dogsNotifier.dogsList[index].id.toString(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        dogsNotifier.dogsList[index].name,
                      ),
                      Text(
                        dogsNotifier.dogsList[index].age.toString() + '歳',
                      ),
                    ],
                  ),
                  Text(
                    dogsNotifier.dogsList[index].createdAt,
                  ),
                ],
              ),
              subtitle: SizedBox(
                width: size.width * .8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Utility.imageFromBase64String(
                    dogsNotifier.dogsList[index].imagePath,
                  ),
                ),
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
                            databaseNotifier
                                .deleteDog(dogsNotifier.dogsList[index].id);
                            dogsNotifier
                                .deleteDog(dogsNotifier.dogsList[index].id);
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
        onPressed: () async {
          final time = DateTime.now().millisecondsSinceEpoch;
          var imageFile;
          var imageString;
          final picker = ImagePicker();
          final pickedFile = await picker.getImage(
            source: ImageSource.gallery,
            maxHeight: 600,
            maxWidth: 800,
          );
          if (pickedFile == null) return;
          imageFile = File(pickedFile.path);

          if (imageFile != null) {
            final Directory directory =
                await getApplicationDocumentsDirectory();
            final String path = directory.path;
            final File newImage = await imageFile.copy('$path/$time.png');

            setState(() {
              imageFile = newImage;
            });

            imageString = Utility.base64String(imageFile.readAsBytesSync());
          }

          final dog = Dog(
            id: dogsNotifier.dogsList.length,
            name: 'dog name',
            age: 10,
            imagePath: imageString,
            createdAt: DateTime.now().toIso8601String(),
          );

          // データベースへ保存 - 挿入
          databaseNotifier.insertDog(dog);
          dogsNotifier.addDog(dog);
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
