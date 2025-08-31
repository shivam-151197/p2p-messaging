import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_p2p/providers/p2p_provider.dart';
import 'package:flutter_p2p/screens/connection_screen.dart';
import 'package:flutter_p2p/screens/peers_screen.dart';
import 'package:flutter_p2p/screens/files_screen.dart';
import 'package:flutter_p2p/screens/share_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter P2P'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<P2PProvider>(
            builder: (context, provider, child) {
              if (provider.isConnected) {
                return IconButton(
                  icon: const Icon(Icons.wifi),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connected to P2P Pool')),
                    );
                  },
                );
              }
              return const Icon(Icons.wifi_off, color: Colors.grey);
            },
          ),
        ],
      ),
      body: Consumer<P2PProvider>(
        builder: (context, provider, child) {
          if (!provider.isConnected) {
            return const ConnectionScreen();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.wifi,
                              color: Colors.green,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Connected to P2P Pool',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    'Device: ${provider.deviceName}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    'ID: ${provider.deviceId}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => provider.refresh(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => provider.disconnect(),
                                icon: const Icon(Icons.logout),
                                label: const Text('Disconnect'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Peers Online',
                        '${provider.peers.length}',
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Files Shared',
                        '${provider.sharedFiles.length}',
                        Icons.folder_shared,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildActionCard(
                        context,
                        'View Peers',
                        Icons.people,
                        Colors.blue,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PeersScreen(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        'Shared Files',
                        Icons.folder_shared,
                        Colors.green,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FilesScreen(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        'Share File',
                        Icons.upload_file,
                        Colors.orange,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShareScreen(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        'Settings',
                        Icons.settings,
                        Colors.grey,
                        () {
                          // TODO: Implement settings screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
