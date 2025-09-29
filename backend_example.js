// Example Node.js/Express backend for Stripe Checkout
// This file shows how to implement the server-side Stripe integration

const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

// Create Checkout Session endpoint
app.post('/create-checkout-session', async (req, res) => {
  try {
    const { items, customerEmail, successUrl, cancelUrl } = req.body;

    // Convert cart items to Stripe line items
    const lineItems = items.map(item => ({
      price_data: {
        currency: 'usd',
        product_data: {
          name: item.product.name,
          description: item.product.description,
          images: [item.product.imageUrl],
          metadata: {
            product_id: item.product.id,
          },
        },
        unit_amount: Math.round(item.product.price * 100), // Convert to cents
      },
      quantity: item.quantity,
    }));

    // Create Stripe Checkout Session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: lineItems,
      mode: 'payment',
      success_url: successUrl,
      cancel_url: cancelUrl,
      customer_email: customerEmail,
      shipping_address_collection: {
        allowed_countries: ['US', 'CA'], // Add countries as needed
      },
      billing_address_collection: 'required',
      metadata: {
        order_date: new Date().toISOString(),
      },
    });

    res.json({ url: session.url });
  } catch (error) {
    console.error('Error creating checkout session:', error);
    res.status(500).json({ error: error.message });
  }
});

// Webhook endpoint to handle Stripe events
app.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  switch (event.type) {
    case 'checkout.session.completed':
      const session = event.data.object;

      // Fulfill the order
      await fulfillOrder(session);

      break;

    case 'payment_intent.payment_failed':
      const paymentIntent = event.data.object;
      console.log('Payment failed:', paymentIntent.id);

      // Send failure notification to customer
      await sendPaymentFailureEmail(paymentIntent.receipt_email);

      break;

    default:
      console.log(`Unhandled event type ${event.type}`);
  }

  res.json({ received: true });
});

async function fulfillOrder(session) {
  // TODO: Implement your order fulfillment logic
  console.log('Fulfilling order for session:', session.id);

  // 1. Save order to database
  // 2. Send confirmation email
  // 3. Update inventory
  // 4. Trigger shipping process

  const customerEmail = session.customer_email || session.customer_details.email;

  // Send confirmation email
  await sendOrderConfirmationEmail(customerEmail, session);
}

async function sendOrderConfirmationEmail(email, orderDetails) {
  // Implement email sending logic
  console.log(`Sending confirmation email to ${email}`);
  // Use SendGrid, AWS SES, or other email service
}

async function sendPaymentFailureEmail(email) {
  // Implement failure notification
  console.log(`Sending payment failure notification to ${email}`);
}

// Get order status (for order tracking page)
app.get('/order-status/:sessionId', async (req, res) => {
  try {
    const session = await stripe.checkout.sessions.retrieve(req.params.sessionId);

    res.json({
      status: session.payment_status,
      customerEmail: session.customer_email,
      amountTotal: session.amount_total / 100, // Convert from cents
      created: session.created,
    });
  } catch (error) {
    res.status(404).json({ error: 'Order not found' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});