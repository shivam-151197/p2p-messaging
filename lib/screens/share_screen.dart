import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_p2p/providers/p2p_provider.dart';
import 'package:flutter_p2p/models/file_info.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  List<FileInfo> _selectedFiles = [];
  List<String> _selectedPeerIds = [];
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Files'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedFiles.isNotEmpty)
            TextButton(
              onPressed: _isSharing ? null : _shareFiles,
              child: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Share'),
            ),
        ],
      ),
      body: Consumer<P2PProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // File Selection Section
              Expanded(
                flex: 2,
                child: _buildFileSelectionSection(),
              ),
              
              // Peer Selection Section
              Expanded(
                flex: 1,
                child: _buildPeerSelectionSection(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFileSelectionSection() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.file_upload, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Select Files to Share',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedFiles.isEmpty
                ? _buildEmptyFileState()
                : _buildSelectedFilesList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.add),
                    label: const Text('Pick Files'),
                  ),
                ),
                if (_selectedFiles.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _clearSelectedFiles,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFileState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.file_upload_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No files selected',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Pick Files" to select files to share',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _selectedFiles.length,
      itemBuilder: (context, index) {
        final fileInfo = _selectedFiles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getFileTypeColor(fileInfo.type),
              child: Icon(
                _getFileTypeIcon(fileInfo.type),
                color: Colors.white,
              ),
            ),
            title: Text(
              fileInfo.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('Size: ${fileInfo.formattedSize}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeFile(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeerSelectionSection(P2PProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.people, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Select Peers to Share With',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.peers.isEmpty
                ? _buildEmptyPeersState()
                : _buildPeersList(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPeersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No peers available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect to the pool to see available peers',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPeersList(P2PProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: provider.peers.length,
      itemBuilder: (context, index) {
        final peer = provider.peers[index];
        final isSelected = _selectedPeerIds.contains(peer.id);
        
        return CheckboxListTile(
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedPeerIds.add(peer.id);
              } else {
                _selectedPeerIds.remove(peer.id);
              }
            });
          },
          title: Text(peer.name),
          subtitle: Text('IP: ${peer.ipAddress}'),
          secondary: CircleAvatar(
            backgroundColor: peer.isOnline ? Colors.green : Colors.grey,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          for (final file in result.files) {
            if (file.path != null) {
              final fileInfo = FileInfo(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: file.name,
                path: file.path!,
                size: file.size,
                type: _getFileTypeFromExtension(file.extension ?? ''),
                senderId: context.read<P2PProvider>().deviceId ?? '',
                timestamp: DateTime.now(),
              );
              _selectedFiles.add(fileInfo);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearSelectedFiles() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  Future<void> _shareFiles() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select files to share'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPeerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select peers to share with'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      bool allShared = true;
      for (final fileInfo in _selectedFiles) {
        final success = await context.read<P2PProvider>().shareFile(
          fileInfo,
          _selectedPeerIds,
        );
        if (!success) {
          allShared = false;
        }
      }

      if (mounted) {
        if (allShared) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully shared ${_selectedFiles.length} file(s)'),
              backgroundColor: Colors.green,
            ),
          );
          // Clear selection and go back
          _clearSelectedFiles();
          _selectedPeerIds.clear();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Some files failed to share'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  String _getFileTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext)) return 'image';
    if (['mp4', 'avi', 'mov', 'wmv', 'flv'].contains(ext)) return 'video';
    if (['mp3', 'wav', 'flac', 'aac'].contains(ext)) return 'audio';
    if (['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(ext)) return 'document';
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) return 'archive';
    return 'other';
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return Colors.red;
      case 'video':
        return Colors.purple;
      case 'audio':
        return Colors.orange;
      case 'document':
        return Colors.blue;
      case 'archive':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getFileTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      case 'audio':
        return Icons.audio_file;
      case 'document':
        return Icons.description;
      case 'archive':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }
}
