import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
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
  void initState() {
    super.initState();
    clearTempDirectory();
  }

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
            final File newImage = await imageFile.copy('$path/1.png');

            imageFile = newImage;
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

          // Documents下のファイルを削除します。
          deleteFile(imageFile);
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Documents下のディレクトリを取得する
  /// @return directory.path : Documents下のディレクトリ
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  /// 該当パスのファイルが存在している際に、返却します
  /// @param imageIndex : 1:認証済み/2:審査中/3:認証失敗/4:画像登録なし(仮画像)
  /// @return 該当パスのファイル
  Future<File> getLocalFile(
    File file,
  ) async {
    if (await File('${file.path}').exists()) {
      return File('${file.path}');
    }
    return null;
  }

  /// 返却されたファイルパスがnull出でない時に、削除します
  void deleteFile(
    File targetFile,
  ) async {
    try {
      final file = await getLocalFile(targetFile);
      if (file != null) {
        await file.delete();
      } else {
        debugPrint('file does not exist');
      }
    } catch (e) {
      debugPrint('Delete file error: $e');
    }
  }

  // iOS - tmp, Android - Cachesディレクトリ内のImagePicker関連画像ファイルを削除します。
  Future<bool> clearTempDirectory() async {
    Directory tmpDirectoryPath;
    if (Platform.isIOS) {
      tmpDirectoryPath = Directory(
        join((await getApplicationDocumentsDirectory())
            .path
            .replaceFirst('Documents', 'tmp')),
      );
    } else {
      tmpDirectoryPath = await getTemporaryDirectory();
    }
    if (tmpDirectoryPath.existsSync()) {
      final length = await tmpDirectoryPath.list().length;
      for (int i = 0; i < length; i++) {
        tmpDirectoryPath
            .list(recursive: true, followLinks: false)
            .listen((FileSystemEntity entity) {
          if (entity.path.contains('image_picker') ||
              entity.path.contains('jpeg')) {
            try {
              if (entity.existsSync()) {
                entity.delete();
                debugPrint('Deleted file: ${entity.path}');
              }
            } catch (e) {
              debugPrint('Delete file error: $e');
            }
          }
        });
      }
    } else {
      debugPrint('$tmpDirectoryPath does not exist');
    }
    return true;
  }
}
