class Peer {
  final String id;
  final String name;
  final String ipAddress;
  final int port;
  final bool isOnline;
  final DateTime lastSeen;

  Peer({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    this.isOnline = true,
    required this.lastSeen,
  });

  factory Peer.fromJson(Map<String, dynamic> json) {
    return Peer(
      id: json['id'],
      name: json['name'],
      ipAddress: json['ipAddress'],
      port: json['port'],
      isOnline: json['isOnline'] ?? true,
      lastSeen: DateTime.parse(json['lastSeen']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': id,
      'ipAddress': ipAddress,
      'port': port,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  Peer copyWith({
    String? id,
    String? name,
    String? ipAddress,
    int? port,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return Peer(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
