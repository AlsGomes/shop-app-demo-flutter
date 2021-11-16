// ignore_for_file: file_names

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/constants.dart';

class ProductListProvider with ChangeNotifier {
  final String _token;
  final String _uid;
  List<Product> _items = [];

  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();

  ProductListProvider([
    this._uid = '',
    this._token = '',
    this._items = const [],
  ]);

  Future<void> fetchProducts() async {
    _items.clear();

    final res =
        await http.get(Uri.parse("${Constants.productsUrl}.json?auth=$_token"));
    if (res.body == 'null') return;

    final favRes = await http.get(
        Uri.parse("${Constants.userFavoritesUrl}/$_uid.json?auth=$_token"));

    Map<String, dynamic> favData =
        favRes.body == 'null' ? {} : jsonDecode(favRes.body);

    final Map<String, dynamic> data = jsonDecode(res.body);
    data.forEach(
      (productId, productData) {
        final isFavorite = favData[productId] ?? false;
        _items.add(
          Product(
            id: productId,
            name: productData["name"],
            description: productData["description"],
            price: productData["price"],
            imageUrl: productData["imageUrl"],
            isFavorite: isFavorite,
          ),
        );
      },
    );
    notifyListeners();
  }

  Future<void> addItem(Product product) async {
    final res = await http.post(
      Uri.parse("${Constants.productsUrl}.json?auth=$_token"),
      body: jsonEncode(
        {
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
        },
      ),
    );

    _items.add(
      Product(
        id: jsonDecode(res.body)['name'],
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        isFavorite: product.isFavorite,
      ),
    );

    notifyListeners();
  }

  Future<void> updateItem(Product product) async {
    int index = _items.indexWhere((prod) => prod.id == product.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse("${Constants.productsUrl}/${product.id}.json?auth=$_token"),
        body: jsonEncode(
          {
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
          },
        ),
      );

      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> saveItem(Map<String, Object> data) {
    bool hasId = data["id"] != null;

    final item = Product(
      id: hasId ? data["id"] as String : Random().nextDouble().toString(),
      name: data["name"] as String,
      description: data["description"] as String,
      price: data["price"] as double,
      imageUrl: data["imageUrl"] as String,
    );

    if (!hasId) {
      return addItem(item);
    } else {
      return updateItem(item);
    }
  }

  Future<void> removeItem(Product product) async {
    int index = _items.indexWhere((prod) => prod.id == product.id);

    if (index >= 0) {
      final prod = _items[index];

      _items.remove(prod);
      notifyListeners();

      final res = await http.delete(
        Uri.parse("${Constants.productsUrl}/${product.id}.json?auth=$_token"),
      );

      if (res.statusCode != 200) {
        _items.insert(index, prod);
        notifyListeners();
        throw HttpException(
          msg: "Exclusão não foi bem sucedida",
          statusCode: res.statusCode,
        );
      }
    }
  }

  int get itemsCount {
    return _items.length;
  }
}
