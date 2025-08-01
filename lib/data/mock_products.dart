import '../models/product.dart';

final List<Product> mockProducts = [
  // Diapers
  Product(
    id: '1',
    name: 'Pampers Soft Baby Diapers',
    category: 'Diapers',
    brand: 'Pampers',
    imageUrl: 'https://images.pexels.com/photos/1667571/pexels-photo-1667571.jpeg?auto=compress&cs=tinysrgb&h=640',
    price: 29.99,
    description: 'Keep your little cutie dry and cozy with our ultra-soft diapers designed for all-day comfort and happy wiggles. Features advanced absorption technology.',
    rating: 4.5,
    reviewCount: 128,
    inStock: true,
    tags: ['newborn', 'comfort', 'ultra-soft', 'all-day'],
  ),
  Product(
    id: '2',
    name: 'Huggies Natural Care Diapers',
    category: 'Diapers',
    brand: 'Huggies',
    imageUrl: 'https://images.pexels.com/photos/1667571/pexels-photo-1667571.jpeg?auto=compress&cs=tinysrgb&h=640',
    price: 32.99,
    description: 'Natural care diapers with plant-based materials for sensitive skin protection.',
    rating: 4.7,
    reviewCount: 95,
    inStock: true,
    tags: ['natural', 'sensitive-skin', 'plant-based'],
  ),

  // Baby Food
  Product(
    id: '3',
    name: 'Gerber Organic Baby Food',
    category: 'Baby Food',
    brand: 'Gerber',
    imageUrl: 'https://images.pexels.com/photos/8999560/pexels-photo-8999560.jpeg?auto=compress&cs=tinysrgb&h=640',
    price: 15.49,
    description: 'Yummy and healthy! This organic baby food is full of nutrients and perfect for growing tummies and tiny taste buds.',
    rating: 4.3,
    reviewCount: 67,
    inStock: true,
    tags: ['organic', 'nutritious', '6-months', 'vegetables'],
  ),
  Product(
    id: '4',
    name: 'Earth\'s Best Fruit Puree',
    category: 'Baby Food',
    brand: 'Earth\'s Best',
    imageUrl: 'https://images.pexels.com/photos/8999560/pexels-photo-8999560.jpeg?auto=compress&cs=tinysrgb&h=640',
    price: 12.99,
    description: 'Organic fruit puree made from the finest ingredients, perfect for baby\'s first foods.',
    rating: 4.6,
    reviewCount: 89,
    inStock: true,
    tags: ['organic', 'fruit', 'first-foods', 'natural'],
  ),

  // Clothing
  Product(
    id: '5',
    name: 'Carter\'s Cute Baby Onesie',
    category: 'Clothing',
    brand: 'Carter\'s',
    imageUrl: 'https://images.unsplash.com/photo-1617059322003-4899fd38f4f7?auto=format&fit=crop&w=640&q=80',
    price: 19.99,
    description: 'Snuggle up in style! This soft, cozy onesie is perfect for cuddles, giggles, and sweet little dreams.',
    rating: 4.4,
    reviewCount: 156,
    inStock: true,
    tags: ['cotton', 'comfortable', 'newborn', 'everyday'],
  ),
  Product(
    id: '6',
    name: 'Baby Gap Sleeper Set',
    category: 'Clothing',
    brand: 'Baby Gap',
    imageUrl: 'https://images.unsplash.com/photo-1617059322003-4899fd38f4f7?auto=format&fit=crop&w=640&q=80',
    price: 24.99,
    description: 'Cozy sleeper set with footies, perfect for peaceful nights and sweet dreams.',
    rating: 4.8,
    reviewCount: 203,
    inStock: false,
    tags: ['sleepwear', 'footies', 'night', 'comfort'],
  ),

  // Toys
  Product(
    id: '7',
    name: 'Fisher-Price Colorful Rattle',
    category: 'Toys',
    brand: 'Fisher-Price',
    imageUrl: 'https://images.unsplash.com/photo-1592715034473-b3d2b4e7693f?auto=format&fit=crop&w=640&q=80',
    price: 8.99,
    description: 'Shake, rattle, and smile! This colorful toy brings joy to little hands and helps develop motor skills.',
    rating: 4.2,
    reviewCount: 74,
    inStock: true,
    tags: ['rattle', 'motor-skills', 'colorful', '3-months'],
  ),
  Product(
    id: '8',
    name: 'VTech Musical Mobile',
    category: 'Toys',
    brand: 'VTech',
    imageUrl: 'https://images.unsplash.com/photo-1592715034473-b3d2b4e7693f?auto=format&fit=crop&w=640&q=80',
    price: 45.99,
    description: 'Soothing musical mobile with rotating animals and gentle melodies for bedtime.',
    rating: 4.9,
    reviewCount: 312,
    inStock: true,
    tags: ['musical', 'mobile', 'bedtime', 'soothing'],
  ),

  // Skincare
  Product(
    id: '9',
    name: 'Johnson\'s Baby Lotion',
    category: 'Skincare',
    brand: 'Johnson\'s',
    imageUrl: 'https://images.pexels.com/photos/1001891/pexels-photo-1001891.jpeg?auto=compress&cs=tinysrgb&h=640',
    price: 12.99,
    description: 'Gentle on baby\'s skin, this silky lotion keeps your little one feeling soft, smooth, and oh-so-huggable.',
    rating: 4.3,
    reviewCount: 189,
    inStock: true,
    tags: ['gentle', 'moisturizing', 'hypoallergenic', 'daily-care'],
  ),
  Product(
    id: '10',
    name: 'Aveeno Baby Wash & Shampoo',
    category: 'Skincare',
    brand: 'Aveeno',
    imageUrl: 'https://images.pexels.com/photos/1001891/pexels-photo-1001891.jpeg?auto=compress&cs=tinysrgb&h=640',
    price: 16.99,
    description: 'Tear-free wash and shampoo with natural oat extract for sensitive baby skin.',
    rating: 4.7,
    reviewCount: 145,
    inStock: true,
    tags: ['tear-free', 'natural', 'oat-extract', 'sensitive-skin'],
  ),

  // Feeding
  Product(
    id: '11',
    name: 'Philips Avent Baby Bottles',
    category: 'Feeding',
    brand: 'Philips Avent',
    imageUrl: 'https://images.pexels.com/photos/6849169/pexels-photo-6849169.jpeg?auto=compress&cs=tinysrgb&h=640',
    price: 22.99,
    description: 'Anti-colic baby bottles with natural latch nipples for comfortable feeding.',
    rating: 4.6,
    reviewCount: 198,
    inStock: true,
    tags: ['anti-colic', 'natural-latch', 'feeding', 'bottles'],
  ),
  Product(
    id: '12',
    name: 'Tommee Tippee Sippy Cup',
    category: 'Feeding',
    brand: 'Tommee Tippee',
    imageUrl: 'https://images.pexels.com/photos/6849169/pexels-photo-6849169.jpeg?auto=compress&cs=tinysrgb&h=640',
    price: 14.99,
    description: 'Spill-proof sippy cup perfect for transitioning from bottles to cups.',
    rating: 4.4,
    reviewCount: 87,
    inStock: true,
    tags: ['spill-proof', 'transition', 'sippy-cup', '6-months'],
  ),

  // Safety
  Product(
    id: '13',
    name: 'Safety 1st Outlet Plugs',
    category: 'Safety',
    brand: 'Safety 1st',
    imageUrl: 'https://images.pexels.com/photos/5709661/pexels-photo-5709661.jpeg?auto=compress&cs=tinysrgb&h=640',
    price: 7.99,
    description: 'Essential childproofing outlet plugs to keep curious little fingers safe.',
    rating: 4.1,
    reviewCount: 92,
    inStock: true,
    tags: ['childproofing', 'safety', 'outlet', 'protection'],
  ),
  Product(
    id: '14',
    name: 'Munchkin Cabinet Locks',
    category: 'Safety',
    brand: 'Munchkin',
    imageUrl: 'https://images.pexels.com/photos/5709661/pexels-photo-5709661.jpeg?auto=compress&cs=tinysrgb&h=640',
    price: 12.99,
    description: 'Easy-to-install cabinet locks to secure cabinets and drawers from little explorers.',
    rating: 4.5,
    reviewCount: 156,
    inStock: true,
    tags: ['cabinet-locks', 'childproofing', 'easy-install', 'security'],
  ),

  // Nursery
  Product(
    id: '15',
    name: 'Skip Hop Night Light',
    category: 'Nursery',
    brand: 'Skip Hop',
    imageUrl: 'https://images.pexels.com/photos/6368871/pexels-photo-6368871.jpeg?auto=compress&cs=tinysrgb&h=640',
    price: 28.99,
    description: 'Soft glow night light with cute animal design for peaceful nursery ambiance.',
    rating: 4.8,
    reviewCount: 234,
    inStock: true,
    tags: ['night-light', 'nursery', 'soft-glow', 'animal-design'],
  ),
];

final List<String> categories = [
  'All',
  'Diapers',
  'Baby Food',
  'Clothing',
  'Toys',
  'Skincare',
  'Feeding',
  'Safety',
  'Nursery',
];

final List<String> brands = [
  'All Brands',
  'Pampers',
  'Huggies',
  'Gerber',
  'Earth\'s Best',
  'Carter\'s',
  'Baby Gap',
  'Fisher-Price',
  'VTech',
  'Johnson\'s',
  'Aveeno',
  'Philips Avent',
  'Tommee Tippee',
  'Safety 1st',
  'Munchkin',
  'Skip Hop',
];