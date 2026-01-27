class MiniaturesEntity {
  int competence;
  int questions;

  MiniaturesEntity({
    required this.competence, 
    required this.questions
  });

  Map<String, Object?> toDocument() {
    return {
      'competence': competence,
      'questions': questions,
    };
  }

  static MiniaturesEntity fromDocument(Map<String, dynamic> doc) {
    return MiniaturesEntity(
      competence: doc['competence'],
      questions: doc['questions'],
    );
  }
}