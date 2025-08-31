# Flutter P2P Server

A Node.js server that acts as a pool coordinator for the Flutter P2P data sharing application.

## Overview

This server provides:
- Device registration and discovery
- Real-time WebSocket communication
- File sharing coordination
- Pool status management

## Features

- **RESTful API**: HTTP endpoints for device management
- **WebSocket Server**: Real-time bidirectional communication
- **Device Pool**: Centralized registry of connected devices
- **File Registry**: Track shared files across the pool
- **CORS Support**: Cross-origin resource sharing enabled
- **Graceful Shutdown**: Proper cleanup on server termination

## Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start the server:**
   ```bash
   # Development mode (auto-restart on file changes)
   npm run dev
   
   # Production mode
   npm start
   ```

## Configuration

### Environment Variables

- `PORT`: Server port (default: 3000)
- `HOST`: Server host (default: 0.0.0.0)

### Network Configuration

For local network access:
- Ensure firewall allows incoming connections on the configured port
- Use the server's local IP address (e.g., `192.168.1.100:3000`)
- All devices must be on the same network

## API Reference

### Device Management

#### Register Device
```
POST /api/register
Content-Type: application/json

{
  "deviceName": "My Device"
}
```

Response:
```json
{
  "deviceId": "uuid-string",
  "message": "Device registered successfully",
  "deviceInfo": {
    "id": "uuid-string",
    "name": "My Device",
    "ipAddress": "192.168.1.100",
    "port": 8000,
    "isOnline": true,
    "lastSeen": "2024-01-01T00:00:00.000Z"
  }
}
```

#### Get Peers
```
GET /api/peers
```

Response:
```json
[
  {
    "id": "uuid-string",
    "name": "Device 1",
    "ipAddress": "192.168.1.100",
    "port": 8000,
    "isOnline": true,
    "lastSeen": "2024-01-01T00:00:00.000Z"
  }
]
```

#### Disconnect Device
```
POST /api/disconnect
Content-Type: application/json

{
  "deviceId": "uuid-string"
}
```

### File Management

#### Share File
```
POST /api/share-file
Content-Type: application/json

{
  "fileInfo": {
    "name": "document.pdf",
    "path": "/path/to/file",
    "size": 1024000,
    "type": "document",
    "senderId": "device-uuid"
  },
  "peerIds": ["peer-uuid-1", "peer-uuid-2"],
  "senderId": "device-uuid"
}
```

#### Get Files
```
GET /api/files
```

### Status & Health

#### Pool Status
```
GET /api/status
```

Response:
```json
{
  "connectedDevices": 5,
  "sharedFiles": 12,
  "uptime": 3600,
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### Health Check
```
GET /health
```

Response:
```json
{
  "status": "OK",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## WebSocket Events

### Client to Server

#### Register WebSocket
```json
{
  "type": "register_ws",
  "deviceId": "uuid-string"
}
```

#### Send Message
```json
{
  "type": "message",
  "to": "target-device-uuid",
  "from": "sender-device-uuid",
  "message": "Hello!",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Server to Client

#### Pool Status Update
```json
{
  "type": "pool_status",
  "connectedDevices": [...],
  "sharedFiles": [...]
}
```

#### Peer Joined
```json
{
  "type": "peer_joined",
  "peer": {
    "id": "uuid-string",
    "name": "New Device",
    "ipAddress": "192.168.1.101",
    "port": 8001,
    "isOnline": true,
    "lastSeen": "2024-01-01T00:00:00.000Z"
  }
}
```

#### Peer Left
```json
{
  "type": "peer_left",
  "peerId": "uuid-string",
  "peer": {
    "id": "uuid-string",
    "name": "Disconnected Device",
    "ipAddress": "192.168.1.101",
    "port": 8001,
    "isOnline": false,
    "lastSeen": "2024-01-01T00:00:00.000Z"
  }
}
```

#### File Shared
```json
{
  "type": "file_shared",
  "file": {
    "id": "file-uuid",
    "name": "document.pdf",
    "path": "/path/to/file",
    "size": 1024000,
    "type": "document",
    "senderId": "device-uuid",
    "timestamp": "2024-01-01T00:00:00.000Z"
  }
}
```

#### Direct Message
```json
{
  "type": "message",
  "from": "sender-device-uuid",
  "message": "Hello!",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## Development

### Project Structure

```
server/
├── package.json      # Dependencies and scripts
├── server.js         # Main server file
└── README.md         # This file
```

### Adding New Features

1. **New API Endpoint**: Add route in `server.js`
2. **New WebSocket Event**: Handle in WebSocket message handler
3. **New Data Model**: Update data structures and validation

### Testing

```bash
# Test server health
curl http://localhost:3000/health

# Test WebSocket connection
wscat -c ws://localhost:3000
```

## Production Deployment

### Security Considerations

- Use HTTPS/WSS in production
- Implement rate limiting
- Add authentication/authorization
- Validate all input data
- Use environment variables for sensitive data

### Performance Optimization

- Implement connection pooling
- Add caching for frequently accessed data
- Use compression middleware
- Monitor memory usage and connections

### Deployment Options

- **Docker**: Containerize the application
- **PM2**: Process manager for Node.js
- **Nginx**: Reverse proxy and load balancer
- **Cloud Platforms**: Deploy to AWS, GCP, or Azure

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Find process using port 3000
   lsof -i :3000
   
   # Kill process
   kill -9 <PID>
   ```

2. **WebSocket Connection Failed**
   - Check firewall settings
   - Verify WebSocket URL
   - Check server logs

3. **CORS Errors**
   - Verify CORS configuration
   - Check client request headers
   - Ensure proper origin handling

### Logs

The server logs important events to the console:
- Device connections/disconnections
- File sharing activities
- WebSocket events
- API requests
- Errors and exceptions

### Monitoring

Monitor server health:
- Response times
- Memory usage
- Active connections
- Error rates

## License

This project is licensed under the MIT License.
