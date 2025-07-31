import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../data/mock_products.dart';
import '../product/product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  final Function(Product) onAddToCart;

  const ProductListScreen({super.key, required this.onAddToCart});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedBrand = 'All Brands';
  double _minPrice = 0;
  double _maxPrice = 100;
  bool _inStockOnly = false;
  double _minRating = 0;
  bool _showFilters = false;

  List<Product> get filteredProducts {
    return mockProducts.where((product) {
      return product.matchesSearch(_searchQuery) &&
             product.matchesFilters(
               selectedCategory: _selectedCategory,
               selectedBrand: _selectedBrand,
               minPrice: _minPrice,
               maxPrice: _maxPrice,
               inStockOnly: _inStockOnly,
               minRating: _minRating,
             );
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedBrand = 'All Brands';
      _minPrice = 0;
      _maxPrice = 100;
      _inStockOnly = false;
      _minRating = 0;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = filteredProducts;

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        title: const Text(
          'BabyShopHub 💕',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search baby items, brands, categories...",
                prefixIcon: const Icon(Icons.search, color: Colors.pink),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                ),
              ),
            ),
          ),

          // Category Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Colors.pink[200],
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.pink[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.pink : Colors.pink[200]!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Advanced Filters Panel
          if (_showFilters)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Brand Filter
                  DropdownButtonFormField<String>(
                    value: _selectedBrand,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      border: OutlineInputBorder(),
                    ),
                    items: brands.map((brand) {
                      return DropdownMenuItem(
                        value: brand,
                        child: Text(brand),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBrand = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price Range
                  Text(
                    'Price Range: \$${_minPrice.toInt()} - \$${_maxPrice.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: Colors.pink,
                    onChanged: (values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Additional Filters
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('In Stock Only'),
                          value: _inStockOnly,
                          onChanged: (value) {
                            setState(() {
                              _inStockOnly = value!;
                            });
                          },
                          activeColor: Colors.pink,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),

                  // Rating Filter
                  Text(
                    'Minimum Rating: ${_minRating.toInt()} stars',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    activeColor: Colors.pink,
                    onChanged: (value) {
                      setState(() {
                        _minRating = value;
                      });
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${products.length} products found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                  ),
              ],
            ),
          ),

          // Product Grid
          Expanded(
            child: products.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(context, product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _clearFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  if (!product.inStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (product.rating >= 4.5)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Top Rated',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.pink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.brand,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (product.rating > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 12,
                              ),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        const Spacer(),
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: product.inStock
                            ? () {
                                widget.onAddToCart(product);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("${product.name} added to cart 🎀"),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            : null,
                        icon: Icon(
                          product.inStock ? Icons.shopping_cart_outlined : Icons.remove_shopping_cart,
                          size: 14,
                        ),
                        label: Text(
                          product.inStock ? "Add" : "Unavailable",
                          style: const TextStyle(fontSize: 11),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: product.inStock ? Colors.pinkAccent : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(0, 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}