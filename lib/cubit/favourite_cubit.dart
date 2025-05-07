import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/favourite.dart';
import 'favourite_state.dart';

class FavouriteCubit extends Cubit<FavouriteState> {
  FavouriteCubit() : super(FavouriteInitial());

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Favourite> _favoriteList = [];

  Future<void> getFavorite() async {
    if (_auth.currentUser == null) return;
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favourites')
        .get();

    _favoriteList = snapshot.docs
        .map((doc) => Favourite(city: doc['city']))
        .toList();

    emit(FavouriteLoaded(favoriteList: List.from(_favoriteList)));
  }

  Future<void> addFavorite(String city) async {
    if (_auth.currentUser == null) return;
    final uid = _auth.currentUser!.uid;

    final exists = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favourites')
        .where('city', isEqualTo: city)
        .get();

    if (exists.docs.isEmpty) {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('favourites')
          .add({'city': city});
    }

    await getFavorite();
  }

  Future<void> deleteFavorite(String city) async {
    if (_auth.currentUser == null) return;
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favourites')
        .where('city', isEqualTo: city)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    await getFavorite();
  }

  bool isFavorite(String city) {
    return _favoriteList.any(
            (fav) => fav.city.toLowerCase() == city.toLowerCase());
  }
}
