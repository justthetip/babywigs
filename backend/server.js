require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);

    // Allow all localhost origins for development
    if (origin.startsWith('http://localhost:') || origin.startsWith('https://localhost:')) {
      return callback(null, true);
    }

    // Allow specific frontend URL from env
    if (origin === process.env.FRONTEND_URL) {
      return callback(null, true);
    }

    // Block all other origins
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true
}));

// Raw body for webhooks (must be before express.json())
app.use('/webhook', express.raw({ type: 'application/json' }));

// JSON parsing for all other routes
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    env: process.env.NODE_ENV
  });
});

// Create Stripe Checkout Session
app.post('/create-checkout-session', async (req, res) => {
  try {
    const { items, customerEmail, successUrl, cancelUrl } = req.body;

    console.log('Creating checkout session for:', {
      customerEmail,
      itemCount: items.length,
      total: items.reduce((sum, item) => sum + (item.product.price * item.quantity), 0)
    });

    // Convert cart items to Stripe line items
    const lineItems = items.map(item => ({
      price_data: {
        currency: 'usd',
        product_data: {
          name: item.product.name,
          description: item.product.description,
          metadata: {
            product_id: item.product.id,
            category: item.product.category,
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
      success_url: `${successUrl}?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: cancelUrl,
      customer_email: customerEmail,
      shipping_address_collection: {
        allowed_countries: ['US', 'CA'], // Add more countries as needed
      },
      billing_address_collection: 'required',
      metadata: {
        customer_email: customerEmail,
        order_date: new Date().toISOString(),
        item_count: items.length.toString(),
      },
      // Enable automatic tax calculation if you have it set up
      // automatic_tax: { enabled: true },
    });

    console.log('Checkout session created:', session.id);

    res.json({
      url: session.url,
      sessionId: session.id
    });

  } catch (error) {
    console.error('Error creating checkout session:', error);
    res.status(500).json({
      error: error.message,
      type: 'checkout_session_creation_failed'
    });
  }
});

// Get session details (for order confirmation)
app.get('/session/:sessionId', async (req, res) => {
  try {
    const session = await stripe.checkout.sessions.retrieve(req.params.sessionId, {
      expand: ['line_items', 'customer']
    });

    res.json({
      id: session.id,
      payment_status: session.payment_status,
      customer_email: session.customer_email || session.customer_details?.email,
      amount_total: session.amount_total / 100, // Convert from cents
      currency: session.currency,
      created: session.created,
      line_items: session.line_items.data.map(item => ({
        description: item.description,
        quantity: item.quantity,
        amount_total: item.amount_total / 100
      }))
    });

  } catch (error) {
    console.error('Error retrieving session:', error);
    res.status(404).json({
      error: 'Session not found',
      type: 'session_not_found'
    });
  }
});

// Stripe webhook endpoint
app.post('/webhook', async (req, res) => {
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
      console.log('Payment successful for session:', session.id);

      // Fulfill the order
      await fulfillOrder(session);
      break;

    case 'checkout.session.expired':
      const expiredSession = event.data.object;
      console.log('Checkout session expired:', expiredSession.id);
      break;

    case 'payment_intent.payment_failed':
      const paymentIntent = event.data.object;
      console.log('Payment failed:', paymentIntent.id);
      break;

    default:
      console.log(`Unhandled event type: ${event.type}`);
  }

  res.json({ received: true });
});

// Order fulfillment function
async function fulfillOrder(session) {
  try {
    console.log('Fulfilling order for session:', session.id);

    // Here you would:
    // 1. Save order to database
    // 2. Send confirmation email
    // 3. Update inventory
    // 4. Create shipping label
    // 5. Send tracking info

    const orderData = {
      sessionId: session.id,
      customerEmail: session.customer_email || session.customer_details?.email,
      amountTotal: session.amount_total / 100,
      currency: session.currency,
      paymentStatus: session.payment_status,
      created: new Date(session.created * 1000),
      metadata: session.metadata
    };

    console.log('Order fulfilled:', orderData);

    // Simulate email sending
    await sendConfirmationEmail(orderData);

  } catch (error) {
    console.error('Error fulfilling order:', error);
  }
}

// Email simulation
async function sendConfirmationEmail(orderData) {
  console.log(`📧 Sending confirmation email to: ${orderData.customerEmail}`);
  console.log(`   Order total: $${orderData.amountTotal}`);
  console.log(`   Session ID: ${orderData.sessionId}`);

  // In production, integrate with:
  // - SendGrid
  // - AWS SES
  // - Mailgun
  // - etc.
}

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Unhandled error:', error);
  res.status(500).json({
    error: 'Internal server error',
    type: 'internal_server_error'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    type: 'not_found'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Baby Wigs Backend Server running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
  console.log(`💳 Stripe mode: ${process.env.STRIPE_SECRET_KEY ? 'configured' : 'NOT CONFIGURED'}`);
  console.log(`🌐 CORS enabled for: ${process.env.FRONTEND_URL || 'http://localhost:54338'}`);
});

module.exports = app;