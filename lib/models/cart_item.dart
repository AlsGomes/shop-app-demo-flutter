import 'package:shop/models/product.dart';

class CartItem {
  final String id;
  final String productId;
  final int quantity;
  final String name;
  final double price;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.name,
    required this.price,
  });
}
