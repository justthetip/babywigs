#!/bin/bash

# Baby Wigs Local Development Setup Script

echo "🍼 Starting Baby Wigs Local Development Environment"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first:"
    echo "   https://nodejs.org/"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Install backend dependencies if needed
if [ ! -d "backend/node_modules" ]; then
    echo "📦 Installing backend dependencies..."
    cd backend && npm install && cd ..
fi

# Check for Stripe keys
if ! grep -q "sk_test_[0-9]" backend/.env; then
    echo ""
    echo "⚠️  IMPORTANT: Set up your Stripe test keys"
    echo "   1. Go to https://dashboard.stripe.com/test/apikeys"
    echo "   2. Copy your test keys"
    echo "   3. Edit backend/.env and replace the placeholder keys"
    echo ""
    echo "   Current backend/.env file:"
    echo "   $(cat backend/.env | grep STRIPE_)"
    echo ""
fi

# Start backend server
echo "🚀 Starting backend server (port 3000)..."
cd backend
node server.js &
BACKEND_PID=$!
cd ..

# Wait for backend to start
sleep 2

# Check if backend is running
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ Backend server is running at http://localhost:3000"
else
    echo "❌ Backend server failed to start"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

echo ""
echo "🚀 Starting Flutter app..."

# Start Flutter app
flutter run -d chrome &
FLUTTER_PID=$!

echo ""
echo "🎉 Baby Wigs is now running!"
echo ""
echo "📱 Flutter app: Check your browser"
echo "🖥️  Backend API: http://localhost:3000"
echo "🏥 Health check: http://localhost:3000/health"
echo ""
echo "Press Ctrl+C to stop both servers"
echo ""

# Function to cleanup background processes
cleanup() {
    echo ""
    echo "🛑 Stopping servers..."
    kill $BACKEND_PID 2>/dev/null
    kill $FLUTTER_PID 2>/dev/null
    echo "👋 Goodbye!"
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup SIGINT SIGTERM

# Wait for Flutter process to end
wait $FLUTTER_PID