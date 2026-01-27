import '../entities/category_entity.dart';
import 'models.dart';

class Categorys {
  String categoryId;
  String picture;
  String name;
  String description;
  Miniatures miniatures;
  String courseId; 

  Categorys({
    required this.categoryId,
    required this.picture,
    required this.name,
    required this.description,
    required this.miniatures,
    required this.courseId,
  });

  CategoryEntity toentity() {
    return CategoryEntity(
      categoryId: categoryId,
      picture: picture,
      name: name,
      description: description,
      miniatures: miniatures,
      courseId: courseId,
    );
  }

  static Categorys fromEntity(CategoryEntity entity) {
    return Categorys(
      categoryId: entity.categoryId,
      picture: entity.picture,
      name: entity.name,
      description: entity.description,
      miniatures: entity.miniatures,
      courseId: entity.courseId,
    );
  }
}
