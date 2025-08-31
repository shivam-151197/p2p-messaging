# Flutter P2P Data Sharing App

A Flutter application that enables peer-to-peer data sharing over WiFi/internet using a Node.js server as a pool coordinator.

## Features

- **P2P Pool Connection**: Connect to a centralized pool to discover other devices
- **Real-time Communication**: WebSocket-based real-time updates for peer discovery and file sharing
- **File Sharing**: Share files with selected peers in the pool
- **Peer Management**: View connected peers and send messages
- **Cross-platform**: Works on both Android and iOS devices
- **Modern UI**: Beautiful Material Design 3 interface

## Architecture

The app uses a hybrid architecture:
- **Centralized Pool**: Node.js server acts as a discovery and coordination service
- **P2P Communication**: Direct peer-to-peer connections for actual file transfers
- **Real-time Updates**: WebSocket connections for live status updates

## Project Structure

```
flutter_p2p/
├── lib/
│   ├── models/           # Data models (Peer, FileInfo)
│   ├── providers/        # State management (P2PProvider)
│   ├── screens/          # UI screens
│   ├── services/         # Business logic (P2PService)
│   └── main.dart         # App entry point
├── server/               # Node.js server
│   ├── package.json      # Server dependencies
│   └── server.js         # Main server file
├── pubspec.yaml          # Flutter dependencies
└── README.md            # This file
```

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Node.js (16.0.0 or higher)
- Android Studio / Xcode for mobile development
- Physical devices or emulators for testing

## Setup Instructions

### 1. Flutter App Setup

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Update server IP address:**
    - Open `lib/services/p2p_service.dart`
    - Update the `_baseUrl` and `_wsUrl` constants with your server's IP address
    - Default: `http://192.168.1.100:3000` (change to your server's IP)

3. **Run the Flutter app:**
   ```bash
   flutter run
   ```

### 2. Node.js Server Setup

1. **Navigate to server directory:**
   ```bash
   cd server
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start the server:**
   ```bash
   # Development mode with auto-restart
   npm run dev
   
   # Production mode
   npm start
   ```

4. **Verify server is running:**
    - HTTP API: `http://localhost:3000/health`
    - WebSocket: `ws://localhost:3000`

## Configuration

### Server Configuration

The server runs on port 3000 by default. You can change this by setting the `PORT` environment variable:

```bash
PORT=8080 npm start
```

### Network Configuration

For the app to work across devices:

1. **Local Network**: Ensure all devices are on the same WiFi network
2. **Firewall**: Allow incoming connections on port 3000
3. **IP Address**: Use the server's local IP address (e.g., `192.168.1.100:3000`)

## Usage

### 1. Start the Server
```bash
cd server
npm start
```

### 2. Launch the Flutter App
- Open the app on multiple devices
- Enter a unique device name
- Tap "Connect to Pool"

### 3. Share Files
- Navigate to "Share File" screen
- Select files to share
- Choose target peers
- Tap "Share"

### 4. View Shared Files
- Navigate to "Shared Files" screen
- See all files shared in the pool
- Download files from other peers

### 5. Manage Peers
- Navigate to "View Peers" screen
- See all connected devices
- Send messages to specific peers

## API Endpoints

### HTTP API
- `POST /api/register` - Register a new device
- `GET /api/peers` - Get all connected peers
- `POST /api/share-file` - Share a file with peers
- `GET /api/files` - Get all shared files
- `POST /api/disconnect` - Disconnect a device
- `GET /api/status` - Get pool status
- `GET /health` - Health check

### WebSocket Events
- `peer_joined` - New peer connected
- `peer_left` - Peer disconnected
- `file_shared` - New file shared
- `message` - Direct message from peer

## Development

### Adding New Features

1. **New Screen**: Create in `lib/screens/`
2. **New Service**: Create in `lib/services/`
3. **New Model**: Create in `lib/models/`
4. **State Management**: Update `lib/providers/p2p_provider.dart`

### Testing

```bash
# Run Flutter tests
flutter test

# Run server tests (if implemented)
cd server
npm test
```

## Troubleshooting

### Common Issues

1. **Connection Failed**
    - Check server is running
    - Verify IP address in `p2p_service.dart`
    - Ensure devices are on same network

2. **File Sharing Not Working**
    - Check file permissions
    - Verify peer selection
    - Check server logs for errors

3. **WebSocket Connection Issues**
    - Check firewall settings
    - Verify WebSocket URL
    - Check server console for connection errors

### Debug Mode

Enable debug logging in the Flutter app by setting `debugShowCheckedModeBanner: true` in `main.dart`.

## Security Considerations

- **Network Security**: Use HTTPS/WSS in production
- **File Validation**: Implement file type and size validation
- **Authentication**: Add user authentication for production use
- **Rate Limiting**: Implement API rate limiting

## Future Enhancements

- [ ] End-to-end encryption for file transfers
- [ ] Direct P2P file transfer without server
- [ ] File compression and optimization
- [ ] Offline mode support
- [ ] Group chat functionality
- [ ] File preview capabilities

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review server logs for errors

---

**Note**: This is a development/prototype version. For production use, implement proper security measures and error handling.
