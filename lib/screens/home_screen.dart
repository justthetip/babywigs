import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<Product> sampleProducts = [
    Product(
      id: 'prod_T95H7Ajj2G9QKR',  // Real Stripe Product ID
      stripePriceId: 'price_1QTwK4FEBCD3125NdJwMrfTy',  // You'll need to create a price for this product
      name: 'The Executive',
      description: 'Perfect for board meetings and power naps. This sophisticated toupee gives your baby instant CEO vibes.',
      price: 5.00,  // Matching your Stripe product price
      imageUrl: 'https://via.placeholder.com/300x300/FFB6C1/FF69B4?text=Executive+Wig',
      features: ['Salt & pepper coloring', 'Comes with tiny briefcase', 'Boardroom-ready'],
      category: 'Professional',
    ),
    Product(
      id: '2',
      stripePriceId: 'price_0987654321',
      name: 'The Rockstar',
      description: 'Let your baby rock out in style! This edgy mohawk is perfect for nursery concerts.',
      price: 34.99,
      imageUrl: 'https://via.placeholder.com/300x300/FFB6C1/FF1493?text=Rockstar+Wig',
      features: ['Vibrant colors', 'Gel-free hold', 'Volume for days'],
      category: 'Fun',
    ),
    Product(
      id: '3',
      stripePriceId: 'price_1122334455',
      name: 'The Einstein',
      description: 'Instant genius look! Wild white hair that says "I understand quantum physics at 6 months old."',
      price: 39.99,
      imageUrl: 'https://via.placeholder.com/300x300/FFB6C1/DDA0DD?text=Einstein+Wig',
      features: ['Authentic wild style', 'Includes mini lab coat', 'IQ boost not guaranteed'],
      category: 'Genius',
    ),
    Product(
      id: '4',
      stripePriceId: 'price_5544332211',
      name: 'The Princess',
      description: 'Golden locks fit for royalty. Your little one will be the belle of the playdate.',
      price: 44.99,
      imageUrl: 'https://via.placeholder.com/300x300/FFB6C1/FFD700?text=Princess+Wig',
      features: ['Flowing golden curls', 'Tiara-compatible', 'Sparkle infused'],
      category: 'Royal',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Baby Wigs',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Tiny Toupees for Tiny Tots',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                iconSize: 28,
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Card(
                  elevation: 0,
                  color: Colors.white70,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.child_care,
                          size: 48,
                          color: Colors.pinkAccent,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Welcome to Baby Wigs!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Because every baby deserves fabulous hair! Browse our collection of premium baby wigs below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ProductCard(product: sampleProducts[index]);
                  },
                  childCount: sampleProducts.length,
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
}