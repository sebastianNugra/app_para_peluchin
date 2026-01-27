part of 'get_categories_bloc.dart';

sealed class GetCategoriesState extends Equatable {
  const GetCategoriesState();

  @override
  List<Object> get props => [];
}

final class GetCategoriesInitial extends GetCategoriesState {}

final class GetCategoriesFailure extends GetCategoriesState {
  final String error;

  const GetCategoriesFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class GetCategoriesLoading extends GetCategoriesState {}

final class GetCategoriesSuccess extends GetCategoriesState {
  final List<Categorys> category;
  const GetCategoriesSuccess(this.category);

  @override
  List<Object> get props => [category];
}
