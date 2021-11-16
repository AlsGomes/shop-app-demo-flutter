import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/order.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/utils/constants.dart';

class OrderProvider with ChangeNotifier {
  final String _token;
  final String _uid;
  List<Order> _items = [];

  OrderProvider([
    this._uid = '',
    this._token = '',
    this._items = const [],
  ]);

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> fetchOrders() async {
    final List<Order> items = [];

    final res = await http
        .get(Uri.parse("${Constants.ordersUrl}/$_uid.json?auth=$_token"));
    if (res.body == 'null') return;

    final Map<String, dynamic> data = jsonDecode(res.body);
    data.forEach(
      (orderId, orderData) {
        items.add(
          Order(
            id: orderId,
            total: orderData['total'],
            products: (orderData['products'] as List<dynamic>)
                .map((item) => CartItem(
                      id: item['id'],
                      productId: item['productId'],
                      quantity: item['quantity'],
                      name: item['name'],
                      price: item['price'],
                    ))
                .toList(),
            date: DateTime.parse(orderData['date']),
          ),
        );
      },
    );

    _items = items.reversed.toList();

    notifyListeners();
  }

  Future<void> addOrder(CartProvider cart) async {
    DateTime date = DateTime.now();
    final res = await http.post(
      Uri.parse("${Constants.ordersUrl}/$_uid.json?auth=$_token"),
      body: jsonEncode(
        {
          "total": cart.totalPrice,
          "date": date.toIso8601String(),
          "products": cart.items.values
              .map((cartItem) => {
                    "id": cartItem.id,
                    "productId": cartItem.id,
                    "quantity": cartItem.quantity,
                    "name": cartItem.name,
                    "price": cartItem.price,
                  })
              .toList(),
        },
      ),
    );

    final String id = jsonDecode(res.body)['name'];

    _items.insert(
      0,
      Order(
        id: id,
        total: cart.totalPrice,
        products: cart.items.values.toList(),
        date: date,
      ),
    );

    notifyListeners();
  }
}
