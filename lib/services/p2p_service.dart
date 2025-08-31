import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_p2p/models/peer.dart';
import 'package:flutter_p2p/models/file_info.dart';

class P2PService {
  static const String _baseUrl = 'http://192.168.1.100:3000'; // Change to your server IP
  static const String _wsUrl = 'ws://192.168.1.100:3000'; // Change to your server IP
  
  WebSocketChannel? _channel;
  String? _deviceId;
  String? _deviceName;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String? get deviceId => _deviceId;
  String? get deviceName => _deviceName;

  // Connect to the P2P pool
  Future<bool> connectToPool(String deviceName) async {
    try {
      _deviceName = deviceName;
      
      // Register device with the server
      final response = await http.post(
        Uri.parse('$_baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceName': deviceName,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _deviceId = data['deviceId'];
        
        // Connect WebSocket for real-time updates
        await _connectWebSocket();
        return true;
      }
      return false;
    } catch (e) {
      print('Error connecting to pool: $e');
      return false;
    }
  }

  // Connect WebSocket for real-time communication
  Future<void> _connectWebSocket() async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsUrl/ws/$_deviceId'),
      );
      
      // Register WebSocket with server
      _channel!.sink.add(json.encode({
        'type': 'register_ws',
        'deviceId': _deviceId,
      }));
      
      _channel!.stream.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error) => print('WebSocket error: $error'),
        onDone: () => _isConnected = false,
      );
      
      _isConnected = true;
    } catch (e) {
      print('WebSocket connection error: $e');
      _isConnected = false;
    }
  }

  // Handle incoming WebSocket messages
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = json.decode(message);
      // Handle different message types
      switch (data['type']) {
        case 'peer_joined':
          // Handle new peer joined
          break;
        case 'peer_left':
          // Handle peer left
          break;
        case 'file_shared':
          // Handle new file shared
          break;
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  // Get list of available peers
  Future<List<Peer>> getPeers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/peers'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> peersData = json.decode(response.body);
        return peersData.map((data) => Peer.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting peers: $e');
      return [];
    }
  }

  // Share a file with peers
  Future<bool> shareFile(FileInfo fileInfo, List<String> peerIds) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/share-file'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fileInfo': fileInfo.toJson(),
          'peerIds': peerIds,
          'senderId': _deviceId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sharing file: $e');
      return false;
    }
  }

  // Get shared files
  Future<List<FileInfo>> getSharedFiles() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/files'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> filesData = json.decode(response.body);
        return filesData.map((data) => FileInfo.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting shared files: $e');
      return [];
    }
  }

  // Download a file from a peer
  Future<bool> downloadFile(FileInfo fileInfo, String peerId) async {
    try {
      // This would implement the actual P2P file transfer
      // For now, we'll just mark it as downloaded
      print('Downloading file ${fileInfo.name} from peer $peerId');
      return true;
    } catch (e) {
      print('Error downloading file: $e');
      return false;
    }
  }

  // Disconnect from the pool
  Future<void> disconnect() async {
    try {
      if (_channel != null) {
        await _channel!.sink.close();
        _channel = null;
      }
      
      if (_deviceId != null) {
        await http.post(
          Uri.parse('$_baseUrl/api/disconnect'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'deviceId': _deviceId}),
        );
      }
      
      _isConnected = false;
      _deviceId = null;
      _deviceName = null;
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // Send message to specific peer
  void sendMessageToPeer(String peerId, String message) {
    if (_channel != null && _isConnected) {
      final data = {
        'type': 'message',
        'to': peerId,
        'from': _deviceId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };
      _channel!.sink.add(json.encode(data));
    }
  }
}
