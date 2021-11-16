import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/product_item.dart';
import 'package:shop/providers/product_list_provider.dart';
import 'package:shop/utils/app_routes.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) {
    return Provider.of<ProductListProvider>(
      context,
      listen: false,
    ).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final ProductListProvider productsProvider =
        Provider.of<ProductListProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Produtos"),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.productForm),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
              itemCount: productsProvider.itemsCount,
              itemBuilder: (ctx, index) {
                return Column(
                  children: [
                    ProductItem(product: productsProvider.items[index]),
                    const Divider(),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
