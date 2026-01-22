class Student {
  String firstName;
  String lastName;
  int age;

  int aciertos;
  int errores;

  Student({
    required this.firstName,
    required this.lastName,
    required this.age,
    this.aciertos = 0,
    this.errores = 0,
  });
}

class Course {
  String name;
  List<Student> students;

  Course({required this.name, List<Student>? students})
    : this.students = students ?? [];
}
