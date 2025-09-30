# CLAUDE.md - Baby Wigs Project Documentation

This file provides comprehensive guidance to Claude Code (claude.ai/code) when working with this repository.

## Project Overview

Baby Wigs is a fully functional ecommerce platform for selling baby wigs, built with Flutter (frontend) and Node.js/Express (backend), integrated with Stripe for payments. The project is deployed in production and actively processing test payments.

## 🌐 Live Production URLs

- **Frontend (Vercel)**: https://web-five-psi-81.vercel.app
- **Backend API (Render)**: https://babywigs.onrender.com
- **Backend Health Check**: https://babywigs.onrender.com/health
- **GitHub Repository**: https://github.com/justthetip/babywigs

## 🛠 Tech Stack

### Frontend
- **Framework**: Flutter (Dart) - Cross-platform support
- **State Management**: Provider pattern
- **Payment Integration**: Stripe Checkout (hosted pages)
- **Hosting**: Vercel (serverless, auto-deploy)
- **Platforms**: Web (primary), iOS, Android (ready)

### Backend
- **Runtime**: Node.js with Express.js
- **Payment Processing**: Stripe API v14
- **Customer Data**: Stored in Stripe (no local database)
- **Hosting**: Render (free tier, auto-deploy from GitHub)
- **CORS**: Configured for all Vercel deployments
- **Webhooks**: Stripe webhook integration for order fulfillment

## 💳 Stripe Configuration

### Test Keys (Stored in .env files)
```
STRIPE_PUBLISHABLE_KEY=pk_test_[your_key_here]
STRIPE_SECRET_KEY=sk_test_[your_key_here]
STRIPE_WEBHOOK_SECRET=whsec_[configured in Stripe Dashboard]
```
Note: Actual keys are stored in `.env` files (not committed to GitHub)

### Products Configured
1. **The Executive** ($5.00) - Product ID: `prod_T95H7Ajj2G9QKR`
2. **The Rockstar** ($34.99) - Fun mohawk style
3. **The Einstein** ($39.99) - Wild genius hair
4. **The Princess** ($44.99) - Golden locks

### Test Payment Card
- Number: `4242 4242 4242 4242`
- Expiry: Any future date
- CVC: Any 3 digits
- ZIP: Any valid ZIP

## 📁 Project Structure

```
babywigs/
├── lib/                    # Flutter application code
│   ├── main.dart          # App entry point with Provider setup
│   ├── models/            # Data models
│   │   ├── product.dart   # Product with Stripe integration
│   │   └── cart_item.dart # Shopping cart items
│   ├── screens/           # UI screens
│   │   ├── home_screen.dart       # Product catalog
│   │   ├── cart_screen.dart       # Shopping cart
│   │   ├── checkout_screen.dart   # Guest checkout form
│   │   └── payment_success_screen.dart # Order confirmation
│   ├── services/          # Business logic
│   │   ├── cart_service.dart      # Cart state management
│   │   └── stripe_checkout_service.dart # Stripe API calls
│   └── widgets/           # Reusable components
│       ├── product_card.dart      # Product display
│       └── cart_item_tile.dart    # Cart item display
├── backend/               # Node.js API server
│   ├── server.js         # Express server with Stripe
│   ├── package.json      # Dependencies
│   ├── render.yaml       # Render deployment config
│   └── .env             # Environment variables (gitignored)
├── web/                   # Flutter web configuration
├── ios/                   # iOS platform files
├── android/               # Android platform files
├── build/                 # Build output (gitignored)
├── render.yaml           # Root Render config for auto-deploy
├── pubspec.yaml          # Flutter dependencies
├── .env                  # Flutter environment variables
├── run-local.sh          # Development startup script
└── CLAUDE.md            # This documentation file
```

## 🚀 Local Development

### Prerequisites
```bash
# Install Flutter
brew install flutter

# Verify Flutter installation
flutter doctor

# Install backend dependencies
cd backend && npm install
```

### Running Locally
```bash
# Quick start (runs both frontend and backend)
./run-local.sh

# OR Manual startup:

# Terminal 1 - Backend (port 3000)
cd backend && npm start

# Terminal 2 - Flutter (auto-selects port)
flutter run -d chrome
```

### Environment Variables
The app automatically switches between development and production:
- **Development Mode**: Uses `http://localhost:3000`
- **Production Mode**: Uses `https://babywigs.onrender.com`

## 🌍 Deployment Process

### Frontend Deployment (Vercel)
```bash
# 1. Build Flutter for production
flutter build web --release

# 2. Deploy to Vercel
cd build/web && vercel --prod --yes

# Note: Vercel auto-deploys are NOT configured for this repo
# Each deployment requires manual push via CLI
```

### Backend Deployment (Render)
Render automatically deploys when you push to GitHub:
```bash
# Make backend changes
git add -A
git commit -m "Your changes"
git push  # This triggers Render auto-deploy
```

Manual deployment via Render Dashboard:
1. Go to https://dashboard.render.com
2. Select `babywigs-backend` service
3. Click "Manual Deploy" → "Deploy latest commit"

### Required Environment Variables (Set in Render Dashboard)
- `NODE_ENV=production`
- `STRIPE_SECRET_KEY` (from Stripe Dashboard)
- `STRIPE_PUBLISHABLE_KEY` (from Stripe Dashboard)
- `STRIPE_WEBHOOK_SECRET` (from Stripe Webhooks)
- `FRONTEND_URL=https://web-five-psi-81.vercel.app`

## 🔄 Payment Flow

1. Customer browses products on Flutter web app
2. Adds items to cart (Provider state management)
3. Proceeds to checkout, enters email
4. Frontend calls backend `/create-checkout-session`
5. Backend creates/retrieves Stripe customer
6. Backend creates Stripe Checkout session
7. Customer redirected to Stripe hosted page
8. Payment processed by Stripe
9. Stripe webhook hits `/webhook` endpoint
10. Backend processes order fulfillment
11. Customer sees success page
12. Stripe sends automatic receipt email

## 🔧 Key Features

### Customer Management
- All customer data stored in Stripe (no local database)
- Customers automatically created on first purchase
- Returning customers recognized by email
- Customer portal available for order history

### CORS Configuration
The backend accepts requests from:
- All `localhost` ports (development)
- Any `*.vercel.app` subdomain (production)
- Specific `FRONTEND_URL` from environment
- The backend's own domain

### Webhook Security
- Webhook endpoint: `POST /webhook`
- Signature verification using `STRIPE_WEBHOOK_SECRET`
- Falls back to unverified mode if secret not configured
- Handles: `checkout.session.completed`, `checkout.session.expired`

## 📝 Common Commands

### Development
```bash
# Run Flutter web locally
flutter run -d chrome

# Run backend locally
cd backend && npm start

# Build Flutter for production
flutter build web --release

# Check Flutter issues
flutter analyze

# Format Dart code
dart format lib/

# Run linting
flutter analyze
```

### Git Operations
```bash
# Stage, commit, and push
git add -A
git commit -m "Description of changes"
git push

# Check deployment status
git log --oneline -5
```

### Testing Production
```bash
# Test backend health
curl https://babywigs.onrender.com/health

# Test CORS configuration
curl -I -X OPTIONS https://babywigs.onrender.com/create-checkout-session \
  -H "Origin: https://web-five-psi-81.vercel.app"

# Monitor logs
# Render: Dashboard → Logs
# Vercel: Dashboard → Functions → Logs
```

## ⚠️ Troubleshooting

### CORS Errors
1. Backend auto-accepts any `*.vercel.app` domain
2. Check Render has deployed latest code (2-3 min delay)
3. Verify in `backend/server.js` CORS settings

### Render Cold Starts
- Free tier spins down after 15 minutes idle
- First request takes 30-50 seconds
- Subsequent requests are fast
- Consider upgrading to Starter ($7/month) for always-on

### Vercel 401/Authentication Errors
1. Go to Vercel Dashboard → Project Settings
2. Set "Deployment Protection" to "Disabled"
3. Or use the production domain URL

### Payment Issues
1. Verify Stripe keys in environment variables
2. Check backend health endpoint
3. Look for errors in browser console
4. Review Stripe Dashboard for failed payments
5. Check webhook logs in Stripe Dashboard

### Manifest.json 401 Errors
- Non-critical PWA manifest issue
- Doesn't affect payment functionality
- Can be ignored or fixed in Vercel settings

## 🔮 Future Enhancements

- [ ] Custom email notifications (SendGrid/Resend integration)
- [ ] Order tracking system with status updates
- [ ] Admin dashboard for inventory management
- [ ] Real product images (replace placeholders)
- [ ] Customer reviews and ratings
- [ ] Discount codes and promotions
- [ ] Shipping cost calculator
- [ ] Multi-currency support
- [ ] Save cart for later (with email)
- [ ] Product search and filtering
- [ ] Mobile app deployment (iOS/Android)

## 📊 Monitoring & Analytics

- **Stripe Dashboard**: https://dashboard.stripe.com/test/payments
- **Render Dashboard**: https://dashboard.render.com
- **Vercel Dashboard**: https://vercel.com/dashboard
- **GitHub Repository**: https://github.com/justthetip/babywigs

## 👤 Contact Information

- **Developer**: Luke Jeffery
- **Email**: luke@lukejeffery.com
- **GitHub**: @justthetip

## 🤖 Notes for Claude

When working on this project:

1. **Always check existing patterns** - Follow established code conventions
2. **Test payment flow** after any backend changes
3. **Monitor deployments** - Render takes 2-3 minutes to deploy
4. **Use TodoWrite tool** for complex multi-step tasks
5. **Run linting** - `flutter analyze` after Flutter changes
6. **Commit frequently** with descriptive messages
7. **CORS is permissive** - Accepts all Vercel domains automatically
8. **No database** - Everything stored in Stripe
9. **Check cold starts** - First Render request may timeout
10. **Update this file** when adding major features

### Quick Checks
```bash
# Is backend healthy?
curl https://babywigs.onrender.com/health

# Latest deployment on GitHub?
git log --oneline -1

# Flutter building correctly?
flutter build web --release
```

### Emergency Fixes
- CORS issues: Push update to `backend/server.js`, wait 3 min
- Payment failures: Check Stripe Dashboard first
- Site down: Check Render and Vercel dashboards
- Cold start timeout: Just retry, it'll wake up

---

**Last Updated**: September 30, 2025
**Version**: 2.0 (Production Deployment)
**Status**: ✅ Fully Deployed and Operational