import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_p2p/providers/p2p_provider.dart';
import 'package:flutter_p2p/models/file_info.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Files'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<P2PProvider>().refresh(),
          ),
        ],
      ),
      body: Consumer<P2PProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.sharedFiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_shared_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No files shared yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Files shared by other peers will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: provider.sharedFiles.length,
              itemBuilder: (context, index) {
                final fileInfo = provider.sharedFiles[index];
                return _buildFileCard(context, fileInfo);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, FileInfo fileInfo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
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
          style: TextStyle(
            fontWeight: fileInfo.isDownloaded ? FontWeight.normal : FontWeight.bold,
            decoration: fileInfo.isDownloaded ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: ${fileInfo.formattedSize}'),
            Text(
              'Shared by: ${fileInfo.senderId}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              'Shared: ${_formatDateTime(fileInfo.timestamp)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Download status
            if (fileInfo.isDownloaded)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
            const SizedBox(width: 8),
            // Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'download':
                    _downloadFile(fileInfo);
                    break;
                  case 'info':
                    _showFileInfo(fileInfo);
                    break;
                }
              },
              itemBuilder: (context) => [
                if (!fileInfo.isDownloaded)
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Download'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info),
                      SizedBox(width: 8),
                      Text('File Info'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showFileInfo(fileInfo),
      ),
    );
  }

  void _downloadFile(FileInfo fileInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download File'),
        content: Text('Are you sure you want to download "${fileInfo.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await context.read<P2PProvider>().downloadFile(
                fileInfo,
                fileInfo.senderId,
              );
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('File "${fileInfo.name}" downloaded successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to download "${fileInfo.name}"'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showFileInfo(FileInfo fileInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', fileInfo.name),
            _buildInfoRow('Size', fileInfo.formattedSize),
            _buildInfoRow('Type', fileInfo.type),
            _buildInfoRow('Sender ID', fileInfo.senderId),
            _buildInfoRow('Shared', _formatDateTime(fileInfo.timestamp)),
            _buildInfoRow('Status', fileInfo.isDownloaded ? 'Downloaded' : 'Available'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!fileInfo.isDownloaded)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _downloadFile(fileInfo);
              },
              child: const Text('Download'),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.red;
      case 'video':
      case 'mp4':
      case 'avi':
      case 'mov':
        return Colors.purple;
      case 'audio':
      case 'mp3':
      case 'wav':
      case 'flac':
        return Colors.orange;
      case 'document':
      case 'pdf':
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'archive':
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getFileTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'video':
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'audio':
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file;
      case 'document':
      case 'pdf':
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'archive':
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
