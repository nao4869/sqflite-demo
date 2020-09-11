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

  List<Dog> get chatsList {
    return [...dogs];
  }

  Future<void> addDog(Dog dog) async {
    final newDog = Dog(
      id: dog.id,
      name: dog.name,
      age: dog.age,
      imagePath: dog.imagePath,
    );
    dogs.add(newDog);
    notifyListeners();
  }

  Future<void> updateDog(
    int id,
    Dog newDog,
  ) async {
    final index = dogs.indexWhere((dog) => dog.id == id);

    dogs[index] = newDog;
    notifyListeners();
  }

  Future<void> deleteDog(int id) async {
    final existingDogIndex = dogs.indexWhere((dog) => dog.id == id);
    dogs.removeAt(existingDogIndex);
    notifyListeners();
  }
}
