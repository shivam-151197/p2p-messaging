import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_p2p/providers/p2p_provider.dart';
import 'package:flutter_p2p/models/peer.dart';

class PeersScreen extends StatefulWidget {
  const PeersScreen({super.key});

  @override
  State<PeersScreen> createState() => _PeersScreenState();
}

class _PeersScreenState extends State<PeersScreen> {
  final TextEditingController _messageController = TextEditingController();
  Peer? _selectedPeer;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showMessageDialog(Peer peer) {
    _selectedPeer = peer;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Message to ${peer.name}'),
        content: TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'Enter your message',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                context.read<P2PProvider>().sendMessageToPeer(
                  peer.id,
                  _messageController.text.trim(),
                );
                _messageController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message sent to ${peer.name}')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Peers'),
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

          if (provider.peers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No peers connected',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Other devices will appear here when they join the pool',
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
              itemCount: provider.peers.length,
              itemBuilder: (context, index) {
                final peer = provider.peers[index];
                return _buildPeerCard(context, peer);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeerCard(BuildContext context, Peer peer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: peer.isOnline ? Colors.green : Colors.grey,
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          peer.name,
          style: TextStyle(
            fontWeight: peer.isOnline ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IP: ${peer.ipAddress}:${peer.port}'),
            Text(
              'Last seen: ${_formatDateTime(peer.lastSeen)}',
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
            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: peer.isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'message':
                    _showMessageDialog(peer);
                    break;
                  case 'info':
                    _showPeerInfo(peer);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'message',
                  child: Row(
                    children: [
                      Icon(Icons.message),
                      SizedBox(width: 8),
                      Text('Send Message'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info),
                      SizedBox(width: 8),
                      Text('Peer Info'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showPeerInfo(peer),
      ),
    );
  }

  void _showPeerInfo(Peer peer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Peer Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', peer.name),
            _buildInfoRow('ID', peer.id),
            _buildInfoRow('IP Address', peer.ipAddress),
            _buildInfoRow('Port', peer.port.toString()),
            _buildInfoRow('Status', peer.isOnline ? 'Online' : 'Offline'),
            _buildInfoRow('Last Seen', _formatDateTime(peer.lastSeen)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessageDialog(peer);
            },
            child: const Text('Send Message'),
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
