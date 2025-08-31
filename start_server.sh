#!/bin/bash

echo "Starting Flutter P2P Server..."
echo "================================"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please install npm first."
    exit 1
fi

# Navigate to server directory
cd server

# Check if node_modules exists, if not install dependencies
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Get local IP address
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "Server will be accessible at:"
echo "  HTTP: http://$LOCAL_IP:3000"
echo "  WebSocket: ws://$LOCAL_IP:3000"
echo ""
echo "Update the IP address in lib/services/p2p_service.dart to: $LOCAL_IP"
echo "================================"

# Start the server
echo "Starting server in development mode..."
npm run dev
