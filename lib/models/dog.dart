class Dog {
  final int id;
  final String name;
  final int age;

  // 追加分
  final String imagePath;

  Dog({
    this.id,
    this.name,
    this.age,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'imagePath': imagePath,
    };
  }

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $age, imagePath: $imagePath}';
  }
}
