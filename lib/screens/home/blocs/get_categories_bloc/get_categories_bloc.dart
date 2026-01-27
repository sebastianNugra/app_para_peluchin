import 'package:bloc/bloc.dart';
import 'package:category_repository/category_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'get_categories_event.dart';
part 'get_categories_state.dart';

class GetCategoriesBloc extends Bloc<GetCategoriesEvent, GetCategoriesState> {
  final CategoryRepo _categoryRepo;

  GetCategoriesBloc(this._categoryRepo) : super(GetCategoriesInitial()) {
    on<GetCategories>((event, emit) async {
      emit(GetCategoriesLoading());
      try {
        List<Categorys> categories = await _categoryRepo.getCategories();
        emit(GetCategoriesSuccess(categories));
      } catch (e, s) {
        debugPrint('ERROR GET CATEGORIES: $e');
        debugPrintStack(stackTrace: s);
        emit(GetCategoriesFailure(e.toString()));
      }
    });
  }
}
