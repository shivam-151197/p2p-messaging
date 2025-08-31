import 'package:flutter/foundation.dart';
import 'package:flutter_p2p/services/p2p_service.dart';
import 'package:flutter_p2p/models/peer.dart';
import 'package:flutter_p2p/models/file_info.dart';

class P2PProvider extends ChangeNotifier {
  final P2PService _p2pService = P2PService();
  
  bool _isConnected = false;
  String? _deviceId;
  String? _deviceName;
  List<Peer> _peers = [];
  List<FileInfo> _sharedFiles = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isConnected => _isConnected;
  String? get deviceId => _deviceId;
  String? get deviceName => _deviceName;
  List<Peer> get peers => _peers;
  List<FileInfo> get sharedFiles => _sharedFiles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Connect to the P2P pool
  Future<bool> connectToPool(String deviceName) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _p2pService.connectToPool(deviceName);
      if (success) {
        _deviceId = _p2pService.deviceId;
        _deviceName = _p2pService.deviceName;
        _isConnected = _p2pService.isConnected;
        
        // Load initial data
        await _loadPeers();
        await _loadSharedFiles();
        
        notifyListeners();
        return true;
      } else {
        _setError('Failed to connect to pool');
        return false;
      }
    } catch (e) {
      _setError('Error connecting to pool: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load available peers
  Future<void> _loadPeers() async {
    try {
      _peers = await _p2pService.getPeers();
      notifyListeners();
    } catch (e) {
      _setError('Error loading peers: $e');
    }
  }

  // Load shared files
  Future<void> _loadSharedFiles() async {
    try {
      _sharedFiles = await _p2pService.getSharedFiles();
      notifyListeners();
    } catch (e) {
      _setError('Error loading shared files: $e');
    }
  }

  // Share a file with peers
  Future<bool> shareFile(FileInfo fileInfo, List<String> peerIds) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _p2pService.shareFile(fileInfo, peerIds);
      if (success) {
        // Reload shared files
        await _loadSharedFiles();
        notifyListeners();
        return true;
      } else {
        _setError('Failed to share file');
        return false;
      }
    } catch (e) {
      _setError('Error sharing file: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Download a file from a peer
  Future<bool> downloadFile(FileInfo fileInfo, String peerId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _p2pService.downloadFile(fileInfo, peerId);
      if (success) {
        // Update file status
        final index = _sharedFiles.indexWhere((f) => f.id == fileInfo.id);
        if (index != -1) {
          _sharedFiles[index] = _sharedFiles[index].copyWith(isDownloaded: true);
          notifyListeners();
        }
        return true;
      } else {
        _setError('Failed to download file');
        return false;
      }
    } catch (e) {
      _setError('Error downloading file: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send message to a peer
  void sendMessageToPeer(String peerId, String message) {
    try {
      _p2pService.sendMessageToPeer(peerId, message);
    } catch (e) {
      _setError('Error sending message: $e');
    }
  }

  // Refresh data
  Future<void> refresh() async {
    if (_isConnected) {
      await _loadPeers();
      await _loadSharedFiles();
    }
  }

  // Disconnect from the pool
  Future<void> disconnect() async {
    _setLoading(true);
    
    try {
      await _p2pService.disconnect();
      _isConnected = false;
      _deviceId = null;
      _deviceName = null;
      _peers.clear();
      _sharedFiles.clear();
      notifyListeners();
    } catch (e) {
      _setError('Error disconnecting: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _p2pService.disconnect();
    super.dispose();
  }
}
