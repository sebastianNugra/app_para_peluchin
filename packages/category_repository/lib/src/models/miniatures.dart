import '../entities/miniatures_entity.dart';

class Miniatures {
  int competence;
  int questions;

  Miniatures({
    required this.competence, 
    required this.questions
  });

  MiniaturesEntity toentity() {
    return MiniaturesEntity(
      competence: competence, 
      questions: questions
      );
  }

  static Miniatures fromEntity(MiniaturesEntity entity) {
    return Miniatures(
      competence: entity.competence, 
      questions: entity.questions
    );
  }
}
