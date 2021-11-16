import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop/utils/constants.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  Future<void> toggleFavorite(String token, String uid) async {
    _toggleFavorite();

    try {
      final res = await http.put(
        Uri.parse("${Constants.userFavoritesUrl}/$uid/$id.json?auth=$token"),
        body: jsonEncode(isFavorite),
      );

      if (res.statusCode != 200) {
        _toggleFavorite();
      }
    } catch (_) {
      _toggleFavorite();
    }
  }
}
