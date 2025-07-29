import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _reviewController = TextEditingController();
  double _starRating = 0;
  List<Map<String, dynamic>> _reviews = [];

  void _submitReview() {
    if (_reviewController.text.isEmpty || _starRating == 0) return;
    setState(() {
      _reviews.add({
        'text': _reviewController.text,
        'rating': _starRating,
      });
      _reviewController.clear();
      _starRating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        title: const Text("Product Details 💖"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                product.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${product.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Add to Cart Button
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text("Add to Cart"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 30),

            // Review Section
            const Text(
              "Customer Reviews",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 10),
            for (var review in _reviews)
              ListTile(
                leading: Icon(Icons.star,
                    color: Colors.amber[600], size: 20 + review['rating'] as double),
                title: Text(review['text']),
                subtitle: Text("Rating: ${review['rating']} ⭐"),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: "Write a review...",
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _starRating = starIndex.toDouble();
                    });
                  },
                  icon: Icon(
                    Icons.star,
                    color: _starRating >= starIndex
                        ? Colors.amber
                        : Colors.grey[400],
                  ),
                );
              }),
            ),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text("Submit Review"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
