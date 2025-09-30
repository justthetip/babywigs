import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/cart_item.dart';

class StripeCheckoutService {
  static final String _publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  // Backend URL - uses local for development, Render for production
  static const String _backendUrl = kDebugMode
      ? 'http://localhost:3000' // Development backend
      : 'https://babywigs.onrender.com'; // Production backend on Render

  Future<String?> createCheckoutSession({
    required List<CartItem> items,
    required String customerEmail,
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      // Call the local backend API to create a Stripe checkout session
      final response = await http.post(
        Uri.parse('$_backendUrl/create-checkout-session'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'items': items.map((item) => {
            'product': {
              'id': item.product.id,
              'name': item.product.name,
              'description': item.product.description,
              'price': item.product.price,
              'category': item.product.category,
            },
            'quantity': item.quantity,
          }).toList(),
          'customerEmail': customerEmail,
          'successUrl': successUrl,
          'cancelUrl': cancelUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      } else {
        if (kDebugMode) {
          print('Backend error: ${response.statusCode} - ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating checkout session: $e');
      }
      return null;
    }
  }

  Future<bool> redirectToCheckout(String checkoutUrl) async {
    try {
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error launching checkout: $e');
      }
      return false;
    }
  }

  // This would be called by your backend webhook handler
  Future<void> handleWebhook(Map<String, dynamic> event) async {
    switch (event['type']) {
      case 'checkout.session.completed':
        // Handle successful payment
        final session = event['data']['object'];
        await _fulfillOrder(session);
        break;
      case 'checkout.session.expired':
        // Handle expired session
        break;
      default:
        print('Unhandled event type: ${event['type']}');
    }
  }

  Future<void> _fulfillOrder(Map<String, dynamic> session) async {
    // Send order confirmation email
    // Update inventory
    // Save order to database
    // etc.
    if (kDebugMode) {
      print('Fulfilling order for session: ${session['id']}');
      print('Customer email: ${session['customer_email']}');
    }
  }
}