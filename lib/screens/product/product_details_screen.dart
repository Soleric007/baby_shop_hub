import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/product.dart';
import '../../data/mock_products.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _reviewController = TextEditingController();
  final _pageController = PageController();
  double _starRating = 0;
  List<Map<String, dynamic>> _reviews = [];
  bool _isFavorite = false;
  int _quantity = 1;
  late TabController _tabController;
  int _currentImageIndex = 0;

  // Mock additional images (in real app, these would come from the product data)
  List<String> get productImages => [
        widget.product.imageUrl,
        widget.product.imageUrl, // Would be different images
        widget.product.imageUrl,
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReviews();
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'reviews_${widget.product.id}';
    final reviewString = prefs.getString(key);
    if (reviewString != null) {
      final List decoded = json.decode(reviewString);
      setState(() {
        _reviews = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      _isFavorite = favorites.contains(widget.product.id);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    
    setState(() {
      if (_isFavorite) {
        favorites.remove(widget.product.id);
        _isFavorite = false;
      } else {
        favorites.add(widget.product.id);
        _isFavorite = true;
      }
    });
    
    await prefs.setStringList('favorites', favorites);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites! 💖' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: _isFavorite ? Colors.pink : Colors.grey,
      ),
    );
  }

  Future<void> _saveReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'reviews_${widget.product.id}';
    await prefs.setString(key, json.encode(_reviews));
  }

  void _submitReview() {
    if (_reviewController.text.trim().isEmpty || _starRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide both rating and review text'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _reviews.insert(0, {
        'text': _reviewController.text.trim(),
        'rating': _starRating,
        'date': DateTime.now().toIso8601String(),
        'userName': 'Anonymous User', // In real app, get from user profile
      });
      _reviewController.clear();
      _starRating = 0;
    });

    _saveReviews();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review submitted successfully! 🌟'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addToCart() {
    // This would typically call a callback or use a state management solution
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${widget.product.name} (x$_quantity) added to cart! 🛒"),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: productImages.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: Image.network(
                  productImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 60,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          
          // Image indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: productImages.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),

          // Favorite button
          Positioned(
            top: 40,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: _toggleFavorite,
              ),
            ),
          ),

          // Stock status badge
          if (!widget.product.inStock)
            Positioned(
              top: 40,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Out of Stock',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and brand
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'by ${widget.product.brand}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),

          // Rating and reviews
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 20,
                    color: index < widget.product.rating.floor()
                        ? Colors.orange
                        : Colors.grey[300],
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount} reviews)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price and quantity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.product.formattedPrice,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (widget.product.inStock)
                Row(
                  children: [
                    const Text('Qty: '),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                : null,
                            iconSize: 18,
                          ),
                          Text(
                            _quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Category and tags
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(
                label: Text(widget.product.category),
                backgroundColor: Colors.pink[100],
                labelStyle: const TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ...widget.product.tags.take(3).map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(color: Colors.grey[700]),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Product Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 12),
          
          // Mock features based on category
          ...widget.product.tags.map((tag) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      tag.replaceAll('-', ' ').toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 16),

          if (_reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "No reviews yet. Be the first to leave one! ⭐",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ..._reviews.map((review) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
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
                          Text(
                            review['userName'] ?? 'Anonymous',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                size: 16,
                                color: index < (review['rating'] as double).floor()
                                    ? Colors.orange
                                    : Colors.grey[300],
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review['text'],
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      if (review['date'] != null)
                        Text(
                          DateTime.parse(review['date']).toLocal().toString().split(' ')[0],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildWriteReviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Write Your Review',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'How would you rate this product?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
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
                  size: 32,
                  color: _starRating >= starIndex
                      ? Colors.orange
                      : Colors.grey[300],
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _reviewController,
            decoration: InputDecoration(
              labelText: 'Share your experience',
              hintText: 'Tell others what you think about this product...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.pink, width: 2),
              ),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitReview,
              icon: const Icon(Icons.send),
              label: const Text('Submit Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.pink[100],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share functionality would go here')),
                  );
                },
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: _buildProductInfo(),
          ),
          
          SliverFillRemaining(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.pink,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.pink,
                  tabs: const [
                    Tab(text: 'Details'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Write Review'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDescriptionTab(),
                      _buildReviewsTab(),
                      _buildWriteReviewTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.pink,
                ),
                label: Text(
                  _isFavorite ? 'Favorited' : 'Add to Favorites',
                  style: TextStyle(color: Colors.pink),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.pink),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: widget.product.inStock ? _addToCart : null,
                icon: Icon(
                  widget.product.inStock ? Icons.shopping_cart : Icons.remove_shopping_cart,
                ),
                label: Text(
                  widget.product.inStock ? 'Add to Cart' : 'Out of Stock',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.product.inStock ? Colors.pinkAccent : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}