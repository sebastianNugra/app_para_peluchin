class Student {
  String id;
  String firstName;
  String lastName;
  int age;

  int aciertos;
  int errores;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    this.aciertos = 0,
    this.errores = 0,
  });
}

class Course {
  final String id;
  String name;
  List<Student> students;

  Course({required this.name, List<Student>? students, required this.id})
    : this.students = students ?? [];
}
