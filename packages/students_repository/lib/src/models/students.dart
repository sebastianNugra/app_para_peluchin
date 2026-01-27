import 'package:students_repository/src/entities/entities.dart';

class Student {
  String id;
  String name;
  int age;
  String course;

  Student({
    required this.id,
    required this.name,
    required this.age,
    required this.course,
  });

  MyStudentsEntity toEntity() {
    return MyStudentsEntity(id: id, name: name, age: age, course: course);
  }

  static Student fromEntity(MyStudentsEntity entity) {
    return Student(
      id: entity.id,
      name: entity.name,
      age: entity.age,
      course: entity.course,
    );
  }
}
