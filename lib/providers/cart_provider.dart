import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/product.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemsCount {
    return _items.length;
  }

  double get totalPrice {
    if (itemsCount == 0) return 0;
    var values = _items.values
        .map((cartItem) => cartItem.price * cartItem.quantity)
        .toList();
    return values.reduce((price1, price2) => (price1 + price2));
  }

  void addItem(Product product) {
    bool hasProduct = _items.containsKey(product.id);

    if (hasProduct) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
            id: existingItem.id,
            productId: product.id,
            quantity: existingItem.quantity + 1,
            name: existingItem.name,
            price: existingItem.price),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
            id: Random().nextDouble().toString(),
            productId: product.id,
            quantity: 1,
            name: product.name,
            price: product.price),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity == 1) {
      removeItem(productId);
    } else {
      _items.update(
        productId,
        (existingItem) => CartItem(
            id: existingItem.id,
            productId: existingItem.id,
            quantity: existingItem.quantity - 1,
            name: existingItem.name,
            price: existingItem.price),
      );
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
