import 'package:meta/meta.dart';
import '../models/favourite.dart';

@immutable
abstract class FavouriteState {}

class FavouriteInitial extends FavouriteState {}

class FavouriteLoaded extends FavouriteState {
  final List<Favourite> favoriteList;

  FavouriteLoaded({required this.favoriteList});
}
