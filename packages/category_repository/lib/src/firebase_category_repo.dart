import 'dart:developer';

import 'package:category_repository/category_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCategoryRepo implements CategoryRepo {
  final categoryCollection = FirebaseFirestore.instance.collection('categories');

  Future<List<Category>> getCategories() async{
    try {
      return await categoryCollection
      .get()
      .then((value) => value.docs.map((e) => 
        Category.fromEntity((CategoryEntity.fromDocument(e.data())))
      ).toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
