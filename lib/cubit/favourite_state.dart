part of 'favourite_cubit.dart';

@immutable
abstract class FavouriteState {}

class FavouriteInitial extends FavouriteState {}

class FavouriteLoaded extends FavouriteState {
  final List<Favourite> favoriteList;

  FavouriteLoaded({required this.favoriteList}) : super();
}