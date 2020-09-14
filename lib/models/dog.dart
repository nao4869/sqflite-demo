class Dog {
  final int id;
  final String name;
  final int age;

  // 追加分
  final String imagePath;
  final String createdAt;

  Dog({
    this.id,
    this.name,
    this.age,
    this.imagePath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'imagePath': imagePath,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $age, imagePath: $imagePath, createdAt: $createdAt}';
  }
}
