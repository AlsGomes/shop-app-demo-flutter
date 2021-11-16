import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop/models/order.dart';

class OrderWidget extends StatefulWidget {
  final Order order;

  const OrderWidget({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final itemHeight = (widget.order.products.length * 25.0) + 10;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _expanded ? itemHeight + 80 : 80,
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Text("R\$ ${widget.order.total.toStringAsFixed(2)}"),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm:ss').format(widget.order.date),
              ),
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                icon: const Icon(Icons.expand_more),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _expanded ? itemHeight : 0,
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 15,
              ),
              child: ListView(
                children: widget.order.products.map(
                  (prod) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          prod.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${prod.quantity}x R\$ ${prod.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                ).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
