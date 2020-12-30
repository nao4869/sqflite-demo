import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_demo/Utility/utility.dart';
import 'package:sqflite_demo/models/todo.dart';
import 'package:sqflite_demo/providers/database_provider.dart';
import 'package:sqflite_demo/providers/todo_provider.dart';
import 'package:sqflite_demo/widgets/text_form_field.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final nameFieldFormKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  String taskName;
  String imageString;
  bool isValid = false;

  void createPostWithoutImage() {
    final notifier = Provider.of<TodoProvider>(context, listen: false);
    final databaseNotifier =
        Provider.of<DataBaseProvider>(context, listen: false);

    /// 保存するTodoインスタンスを作成
    final todo = Todo(
      id: notifier.todoList.length,
      name: taskName,
      createdAt: DateTime.now().toIso8601String(),
      imagePath: imageString,
    );
    notifier.addTodo(todo);
    databaseNotifier.insertTodo(todo);
  }

  /// 画像ファイルをストレージにアップロードする関数です
  Future chooseFile() async {
    final time = DateTime.now().millisecondsSinceEpoch;
    var imageFile;
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 600,
      maxWidth: 800,
    );
    if (pickedFile == null) return;
    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final File newImage = await imageFile.copy('$path/$time.png');

      imageFile = newImage;
      setState(() {});

      imageString = Utility.base64String(imageFile.readAsBytesSync());
    }
  }

  void onNameChange(String text) {
    isValid = text.isNotEmpty;
    taskName = text;
    setState(() {});
  }

  void resetNameTextField() {
    onNameChange('');
    nameFieldFormKey.currentState.reset();
    taskName = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final databaseNotifier = Provider.of<DataBaseProvider>(context);
    final todoNotifier = Provider.of<TodoProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SQLite',
        ),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: todoNotifier.todoList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    todoNotifier.todoList[index].name,
                  ),
                  Text(
                    todoNotifier.todoList[index].createdAt.substring(0, 10),
                  ),
                ],
              ),
              subtitle: todoNotifier.todoList[index].imagePath != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: SizedBox(
                        width: size.width * .8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Utility.imageFromBase64String(
                            todoNotifier.todoList[index].imagePath,
                          ),
                        ),
                      ),
                    )
                  : Container(),
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
                                .deleteDog(todoNotifier.todoList[index].id);
                            todoNotifier
                                .deleteTodo(todoNotifier.todoList[index].id);
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
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return _buildAddTaskDialog(
                    setState,
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// TODOタスク追加時の表示ダイアログ
  Widget _buildAddTaskDialog(
    Function setState,
  ) {
    return SimpleDialog(
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {},
          child: Column(
            children: [
              CustomTextFormField(
                formKey: nameFieldFormKey,
                height: 80,
                onChanged: onNameChange,
                controller: textController,
                resetTextField: resetNameTextField,
                hintText: 'タスク名',
                counterText: '50',
              ),
              const SizedBox(height: 10),
              imageString != null
                  ? SizedBox(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Image.memory(
                          base64Decode(imageString),
                          gaplessPlayback: true,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildRaisedButton(
                    title: '画像を追加する',
                    onPressed: () async {
                      await chooseFile();
                      await setState(() {});
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildRaisedButton(
                    title: '投稿する',
                    onPressed: () {
                      // ダイアログを閉じます
                      Navigator.of(context).pop();
                      createPostWithoutImage();
                    },
                  ),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRaisedButton({
    @required String title,
    @required VoidCallback onPressed,
  }) {
    return RaisedButton(
      color: Colors.blue,
      elevation: 0,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
