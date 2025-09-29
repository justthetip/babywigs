# Baby Wigs - Tiny Toupees for Tiny Tots

A playful ecommerce platform for selling baby wigs, built with Flutter for web, iOS, and Android. Features guest checkout with email confirmation powered by Stripe.

## Features

- Cross-platform support (Web, iOS, Android)
- Guest checkout with email confirmation
- Stripe payment integration
- Shopping cart functionality
- Product catalog with fun baby wig designs
- Order confirmation emails
- Responsive design

## Setup Instructions

### Prerequisites

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Create a Stripe account: https://stripe.com
3. Get your Stripe API keys from the Stripe Dashboard

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/babywigs.git
cd babywigs
```

2. Create a `.env` file from the example:
```bash
cp .env.example .env
```

3. Add your Stripe keys to `.env`:
```
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_key_here
```

4. Install dependencies:
```bash
flutter pub get
```

5. Run the app:
```bash
# For web
flutter run -d chrome

# For iOS (requires macOS and Xcode)
flutter run -d ios

# For Android
flutter run -d android
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── product.dart
│   └── cart_item.dart
├── screens/               # App screens
│   ├── home_screen.dart
│   ├── cart_screen.dart
│   └── checkout_screen.dart
├── services/              # Business logic
│   ├── cart_service.dart
│   └── stripe_service.dart
└── widgets/               # Reusable components
    ├── product_card.dart
    └── cart_item_tile.dart
```

## Stripe Setup

1. Create products in your Stripe Dashboard
2. Add the price IDs to the products in `home_screen.dart`
3. Configure webhook endpoints for order processing (optional)

## Security Notes

- Never commit your `.env` file with real API keys
- Use test keys for development
- Implement proper backend API for production
- Add authentication for returning customers
- Secure your API endpoints

## License

This is a demo project for educational purposes.