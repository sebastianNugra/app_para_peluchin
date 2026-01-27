import 'models/models.dart';

abstract class CategoryRepo {
    Future<List<Categorys>> getCategories();

}