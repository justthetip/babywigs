# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Baby Wigs is a playful ecommerce platform for selling baby wigs, built with Flutter for cross-platform deployment (Web, iOS, Android). It uses Stripe as a headless commerce solution with guest checkout capabilities.

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Payment Processing**: Stripe (flutter_stripe package)
- **Platforms**: Web, iOS, Android

## Project Structure

```
lib/
├── main.dart              # App entry point, providers setup
├── models/                # Data models
│   ├── product.dart       # Product model with Stripe price IDs
│   └── cart_item.dart     # Cart item model
├── screens/               # App screens
│   ├── home_screen.dart   # Product catalog display
│   ├── cart_screen.dart   # Shopping cart management
│   └── checkout_screen.dart # Guest checkout with email
├── services/              # Business logic
│   ├── cart_service.dart  # Cart state management
│   └── stripe_service.dart # Stripe payment integration
└── widgets/               # Reusable UI components
    ├── product_card.dart  # Product display card
    └── cart_item_tile.dart # Cart item display
```

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run on different platforms
flutter run -d chrome     # Web
flutter run -d ios        # iOS (requires macOS/Xcode)
flutter run -d android    # Android

# Build for production
flutter build web
flutter build ios
flutter build apk

# Run tests (when implemented)
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

## Key Implementation Details

### Guest Checkout Flow
1. Customer adds products to cart
2. Proceeds to checkout without account creation
3. Provides email for order confirmation
4. Payment processed via Stripe
5. Order confirmation sent to email

### Stripe Integration
- Uses `flutter_stripe` for native payment UI
- Requires `.env` file with Stripe keys (see `.env.example`)
- Payment intents created server-side (needs backend implementation)
- Guest checkout with email receipts

### State Management
- Uses Provider pattern for cart state
- CartService manages shopping cart operations
- Real-time UI updates via ChangeNotifier

## Environment Setup

1. Create `.env` file from `.env.example`
2. Add Stripe API keys (test keys for development)
3. Configure Stripe products with price IDs
4. Update product stripePriceId in home_screen.dart

## Development Notes

- Sample products are hardcoded in `home_screen.dart` for demo purposes
- Backend API needed for production (payment intent creation, order processing)
- Email service integration required for order confirmations
- Consider adding product image assets or CDN URLs
- Fonts (Quicksand) need to be added to assets/fonts/ directory