class Todo {
  final int id;
  final String name;

  // 追加分
  final String imagePath;
  final String createdAt;

  Todo({
    this.id,
    this.name,
    this.imagePath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, imagePath: $imagePath, createdAt: $createdAt}';
  }
}
