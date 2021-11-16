import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/order_widget.dart';
import 'package:shop/providers/order_provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => _isLoading = true);
    await Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Pedidos"),
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchOrders,
              child: ListView.builder(
                itemBuilder: (ctx, index) => OrderWidget(
                  order: orderProvider.items[index],
                ),
                itemCount: orderProvider.itemsCount,
              ),
            ),
    );
  }
}
