import '../entities/category_entity.dart';
import 'models.dart';

class Category {
  String categoryId;
  String picture;
  String name;
  String description;
  Miniatures miniatures;

  Category({
    required this.categoryId,
    required this.picture,
    required this.name,
    required this.description,
    required this.miniatures,
  });

  CategoryEntity toentity() {
    return CategoryEntity(
      categoryId: categoryId,
      picture: picture,
      name: name,
      description: description,
      miniatures: miniatures,
    );
  }

  static Category fromEntity(CategoryEntity entity) {
    return Category(
      categoryId: entity.categoryId,
      picture: entity.picture,
      name: entity.name,
      description: entity.description,
      miniatures: entity.miniatures,
    );
  }
}
