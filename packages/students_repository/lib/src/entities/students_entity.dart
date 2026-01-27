class MyStudentsEntity {
  String id;
  String name;
  int age;
  String course;
  int? aciertos;
  int? errores;

  MyStudentsEntity({
    required this.id,
    required this.name,
    required this.age,
    required this.course,
    this.aciertos,
    this.errores,
  });

  Map<String, Object?> toDocument() {
    return {'id': id, 'name': name, 'age': age, 'course': course};
  }

  static MyStudentsEntity fromDocument(Map<String, dynamic> doc) {
    return MyStudentsEntity(
      id: doc['id'],
      name: doc['name'],
      age: doc['age'],
      course: doc['course'],
      aciertos: doc['aciertos'],
      errores: doc['errores'],
    );
  }
}
