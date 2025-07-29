import 'package:flutter/material.dart';
import '../../data/mock_products.dart';
import '../../models/product.dart';
import 'product_details_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        title: const Text('BabyShopHub 💕'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: mockProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6, // smaller card size
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final product = mockProducts[index];
                  return _buildProductCard(context, product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search baby items...",
        prefixIcon: const Icon(Icons.search, color: Colors.pink),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product)),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                product.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                  fontSize: 14,
                ),
              ),
            ),
            Text("\$${product.price.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                )),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                label: const Text("Add"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
