# Baby Wigs Backend

Local backend server for Baby Wigs ecommerce app with Stripe integration.

## Quick Setup

1. **Install Node.js** (if not already installed):
   ```bash
   # Check if Node.js is installed
   node --version

   # If not installed, download from https://nodejs.org
   ```

2. **Install dependencies**:
   ```bash
   cd backend
   npm install
   ```

3. **Set up Stripe keys**:
   - Get your test keys from [Stripe Dashboard](https://dashboard.stripe.com/test/apikeys)
   - Edit `.env` file and replace the placeholder keys:
   ```
   STRIPE_SECRET_KEY=sk_test_your_actual_secret_key_here
   STRIPE_PUBLISHABLE_KEY=pk_test_your_actual_publishable_key_here
   ```

4. **Start the server**:
   ```bash
   npm run dev
   ```

The server will run on http://localhost:3000

## Testing the Integration

1. Start the backend server (this terminal)
2. Start Flutter app in another terminal: `flutter run -d chrome`
3. Add items to cart and proceed to checkout
4. Enter email and click "Proceed to Payment"
5. You'll be redirected to real Stripe Checkout!

## API Endpoints

- `GET /health` - Health check
- `POST /create-checkout-session` - Create Stripe checkout session
- `GET /session/:sessionId` - Get session details
- `POST /webhook` - Stripe webhook handler

## Webhook Testing (Optional)

To test webhooks locally, install Stripe CLI:

1. Install Stripe CLI: https://stripe.com/docs/stripe-cli
2. Login: `stripe login`
3. Forward webhooks: `stripe listen --forward-to localhost:3000/webhook`
4. Copy the webhook secret to `.env`

## Logs

The server logs all important events:
- Checkout session creation
- Payment completion
- Order fulfillment
- Errors