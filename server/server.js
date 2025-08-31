const express = require('express');
const WebSocket = require('ws');
const http = require('http');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Store connected devices and shared files
const connectedDevices = new Map();
const sharedFiles = new Map();
const deviceWebSockets = new Map();

// Helper function to broadcast to all connected devices
function broadcastToAll(message) {
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(message));
    }
  });
}

// Helper function to broadcast to specific device
function broadcastToDevice(deviceId, message) {
  const ws = deviceWebSockets.get(deviceId);
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(message));
  }
}

// WebSocket connection handler
wss.on('connection', (ws, req) => {
  console.log('New WebSocket connection established');
  
  let deviceId = null;
  
  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      
      if (data.type === 'register_ws') {
        deviceId = data.deviceId;
        deviceWebSockets.set(deviceId, ws);
        console.log(`Device ${deviceId} WebSocket registered`);
        
        // Send current pool status
        ws.send(JSON.stringify({
          type: 'pool_status',
          connectedDevices: Array.from(connectedDevices.values()),
          sharedFiles: Array.from(sharedFiles.values()),
        }));
      } else if (data.type === 'message') {
        // Forward message to specific peer
        const targetDevice = connectedDevices.get(data.to);
        if (targetDevice) {
          broadcastToDevice(data.to, {
            type: 'message',
            from: data.from,
            message: data.message,
            timestamp: data.timestamp,
          });
        }
      }
    } catch (error) {
      console.error('Error processing WebSocket message:', error);
    }
  });
  
  ws.on('close', () => {
    if (deviceId) {
      deviceWebSockets.delete(deviceId);
      console.log(`Device ${deviceId} WebSocket disconnected`);
    }
  });
  
  ws.on('error', (error) => {
    console.error('WebSocket error:', error);
  });
});

// API Routes

// Register a new device
app.post('/api/register', (req, res) => {
  try {
    const { deviceName } = req.body;
    
    if (!deviceName || deviceName.trim().length < 3) {
      return res.status(400).json({ error: 'Device name must be at least 3 characters' });
    }
    
    const deviceId = uuidv4();
    const deviceInfo = {
      id: deviceId,
      name: deviceName.trim(),
      ipAddress: req.ip || req.connection.remoteAddress || 'unknown',
      port: Math.floor(Math.random() * 10000) + 8000, // Random port for P2P
      isOnline: true,
      lastSeen: new Date(),
    };
    
    connectedDevices.set(deviceId, deviceInfo);
    
    // Broadcast new peer joined
    broadcastToAll({
      type: 'peer_joined',
      peer: deviceInfo,
    });
    
    console.log(`Device registered: ${deviceName} (${deviceId})`);
    
    res.json({
      deviceId,
      message: 'Device registered successfully',
      deviceInfo,
    });
  } catch (error) {
    console.error('Error registering device:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all connected peers
app.get('/api/peers', (req, res) => {
  try {
    const peers = Array.from(connectedDevices.values());
    res.json(peers);
  } catch (error) {
    console.error('Error getting peers:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Share a file
app.post('/api/share-file', (req, res) => {
  try {
    const { fileInfo, peerIds, senderId } = req.body;
    
    if (!fileInfo || !peerIds || !senderId) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const fileId = uuidv4();
    const sharedFile = {
      ...fileInfo,
      id: fileId,
      timestamp: new Date(),
    };
    
    sharedFiles.set(fileId, sharedFile);
    
    // Broadcast file shared to all peers
    broadcastToAll({
      type: 'file_shared',
      file: sharedFile,
    });
    
    console.log(`File shared: ${fileInfo.name} by ${senderId}`);
    
    res.json({
      message: 'File shared successfully',
      fileId,
    });
  } catch (error) {
    console.error('Error sharing file:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all shared files
app.get('/api/files', (req, res) => {
  try {
    const files = Array.from(sharedFiles.values());
    res.json(files);
  } catch (error) {
    console.error('Error getting files:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Disconnect a device
app.post('/api/disconnect', (req, res) => {
  try {
    const { deviceId } = req.body;
    
    if (!deviceId) {
      return res.status(400).json({ error: 'Device ID is required' });
    }
    
    const device = connectedDevices.get(deviceId);
    if (device) {
      device.isOnline = false;
      device.lastSeen = new Date();
      
      // Broadcast peer left
      broadcastToAll({
        type: 'peer_left',
        peerId: deviceId,
        peer: device,
      });
      
      console.log(`Device disconnected: ${device.name} (${deviceId})`);
    }
    
    res.json({ message: 'Device disconnected successfully' });
  } catch (error) {
    console.error('Error disconnecting device:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get pool status
app.get('/api/status', (req, res) => {
  try {
    const status = {
      connectedDevices: connectedDevices.size,
      sharedFiles: sharedFiles.size,
      uptime: process.uptime(),
      timestamp: new Date(),
    };
    res.json(status);
  } catch (error) {
    console.error('Error getting status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() });
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Flutter P2P Server running on port ${PORT}`);
  console.log(`Server accessible at http://localhost:${PORT}`);
  console.log(`WebSocket accessible at ws://localhost:${PORT}`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\nShutting down server...');
  wss.close(() => {
    console.log('WebSocket server closed');
    server.close(() => {
      console.log('HTTP server closed');
      process.exit(0);
    });
  });
});

process.on('SIGTERM', () => {
  console.log('\nShutting down server...');
  wss.close(() => {
    console.log('WebSocket server closed');
    server.close(() => {
      console.log('HTTP server closed');
      process.exit(0);
    });
  });
});
