// lib/screens/admin/add_edit_product_screen.dart
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/admin_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();
  final brandController = TextEditingController(); // Added brand controller
  
  String selectedCategory = 'Diapers';
  final List<String> categories = [
    'Diapers',
    'Baby Food',
    'Clothing',
    'Toys',
    'Skincare',
    'Feeding',
    'Safety',
    'Accessories',
  ];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      loadProductData();
    }
  }

  void loadProductData() {
    final product = widget.product!;
    nameController.text = product.name;
    priceController.text = product.price.toString();
    descriptionController.text = product.description;
    imageUrlController.text = product.imageUrl;
    brandController.text = product.brand; // Load brand data
    selectedCategory = product.category;
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final product = Product(
        id: widget.product?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
        name: nameController.text.trim(),
        price: double.parse(priceController.text.trim()),
        description: descriptionController.text.trim(),
        imageUrl: imageUrlController.text.trim(),
        brand: brandController.text.trim(), // Include brand parameter
        category: selectedCategory,
      );

      if (widget.product == null) {
        await AdminService.addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await AdminService.updateProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully! ✅'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          isEditing ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview
              if (imageUrlController.text.isNotEmpty)
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              _buildTextField(
                controller: nameController,
                label: 'Product Name',
                hint: 'e.g. Soft Baby Diapers',
                icon: Icons.label,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),

              // Brand field (new)
              _buildTextField(
                controller: brandController,
                label: 'Brand',
                hint: 'e.g. Pampers, Huggies',
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter brand name';
                  }
                  return null;
                },
              ),

              // Category Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ),

              _buildTextField(
                controller: priceController,
                label: 'Price (₦)',
                hint: 'e.g. 29.99',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: imageUrlController,
                label: 'Image URL',
                hint: 'https://example.com/image.jpg',
                icon: Icons.image,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter image URL';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: descriptionController,
                label: 'Description',
                hint: 'Detailed product description...',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: isLoading ? null : saveProduct,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(isEditing ? Icons.update : Icons.add),
                label: Text(
                  isLoading
                      ? 'Saving...'
                      : isEditing
                          ? 'Update Product'
                          : 'Add Product',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}