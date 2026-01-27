import 'package:category_repository/src/entities/miniatures_entity.dart';

import '../models/miniatures.dart';

class CategoryEntity {
  String categoryId;
  String picture;
  String name;
  String description;
  Miniatures miniatures;

  CategoryEntity({
    required this.categoryId,
    required this.picture,
    required this.name,
    required this.description,
    required this.miniatures,
  });

  Map<String, Object?> toDocument() {
    return {
      'categoryId': categoryId,
      'picture': picture,
      'name': name,
      'description': description,
      'miniatures': miniatures.toentity().toDocument(),
    };
  }

  static CategoryEntity fromDocument(Map<String, dynamic> doc) {
    return CategoryEntity(
      categoryId: doc['categoryId'],
      picture: doc['picture'],
      name: doc['name'],
      description: doc['description'],
      miniatures: Miniatures.fromEntity(MiniaturesEntity.fromDocument(doc['miniatures'])),
    );
  }
}
