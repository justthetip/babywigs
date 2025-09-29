import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';

class StripeService {
  static final String _baseUrl = dotenv.env['STRIPE_API_URL'] ?? '';
  static final String _secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerEmail,
    required List<CartItem> items,
  }) async {
    try {
      final amountInCents = (amount * 100).toInt();

      final response = await http.post(
        Uri.parse('$_baseUrl/payment-intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amountInCents,
          'currency': currency,
          'receipt_email': customerEmail,
          'metadata': {
            'order_items': jsonEncode(items.map((item) => {
              'product_id': item.product.id,
              'product_name': item.product.name,
              'quantity': item.quantity,
              'price': item.product.price,
            }).toList()),
          },
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating payment intent: $e');
      }
      return null;
    }
  }

  Future<bool> processGuestCheckout({
    required String email,
    required List<CartItem> cartItems,
    required double totalAmount,
  }) async {
    try {
      // Simplified checkout - in production, integrate with Stripe SDK
      final paymentIntent = await createPaymentIntent(
        amount: totalAmount,
        currency: 'usd',
        customerEmail: email,
        items: cartItems,
      );

      if (paymentIntent == null) return false;

      // TODO: Integrate Stripe payment sheet when flutter_stripe_web is fixed
      // For now, simulating successful payment
      await Future.delayed(const Duration(seconds: 2));

      await sendOrderConfirmation(email, cartItems, totalAmount);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Payment error: $e');
      }
      return false;
    }
  }

  Future<void> sendOrderConfirmation(
    String email,
    List<CartItem> items,
    double total,
  ) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/send-confirmation'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': email,
          'items': items.map((item) => item.toJson()).toList(),
          'total': total,
          'orderDate': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending confirmation: $e');
      }
    }
  }
}