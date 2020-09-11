import 'package:flutter/material.dart';
import 'package:sqflite_demo/models/dog.dart';

class DogsProvider with ChangeNotifier {
  DogsProvider({
    this.dogs,
  });

  List<Dog> dogs;

  BuildContext context;

  Dog getFirstDog() {
    return dogs.first;
  }

  // getter for all chats
  List<Dog> get chatsList {
    return [...dogs];
  }

  Future<void> addDog(Dog dog) async {
    final newDog = Dog(
      id: dog.id,
      name: dog.name,
      age: dog.age,
    );
    dogs.add(newDog);
    notifyListeners();
  }

//  Future<void> updateChat(int id, Chat newChat) async {
//    final chatIndex = chats.indexWhere((ch) => ch.id == id);
//
//    chats[chatIndex] = newChat;
//    notifyListeners();
//  }
//
//  Future<void> deleteChat(int id) async {
//    final existingChatIndex = chats.indexWhere((chat) => chat.id == id);
//    chats.removeAt(existingChatIndex);
//    notifyListeners();
//  }
//
//  Future<void> deleteRoomChats(int chatRoomId) async {
//    final chatList =
//    chats.where((element) => element.roomId == chatRoomId).toList();
//
//    for (int i = 0; i < chatList.length; i++) {
//      final existingChatIndex =
//      chatList.indexWhere((chat) => chat.roomId == chatRoomId);
//      chatList.removeAt(existingChatIndex);
//    }
//    notifyListeners();
//  }
}