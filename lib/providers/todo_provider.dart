import 'package:flutter/material.dart';
import 'package:sqflite_demo/models/todo.dart';

class TodoProvider with ChangeNotifier {
  TodoProvider({
    this.todoList,
  });

  List<Todo> todoList;

  BuildContext context;

  Todo getFirstTodo() {
    return todoList.first;
  }

  List<Todo> get getTodoList {
    // 新規投稿作成時に、作成日が新しい順番でソートされたリストを返却
    todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return [...todoList];
  }

  Future<void> addTodo(Todo todo) async {
    final newTodo = Todo(
      id: todo.id,
      name: todo.name,
      imagePath: todo.imagePath,
      createdAt: todo.createdAt,
    );
    todoList.add(newTodo);
    notifyListeners();
  }

  Future<void> updateTodo(
    int id,
    Todo newTodo,
  ) async {
    final index = todoList.indexWhere((todo) => todo.id == id);

    todoList[index] = newTodo;
    notifyListeners();
  }

  Future<void> deleteTodo(int id) async {
    final existingTodoIndex = todoList.indexWhere((todo) => todo.id == id);
    todoList.removeAt(existingTodoIndex);
    notifyListeners();
  }
}
