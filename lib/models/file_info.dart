class FileInfo {
  final String id;
  final String name;
  final String path;
  final int size;
  final String type;
  final String senderId;
  final DateTime timestamp;
  final bool isDownloaded;

  FileInfo({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.type,
    required this.senderId,
    required this.timestamp,
    this.isDownloaded = false,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      size: json['size'],
      type: json['type'],
      senderId: json['senderId'],
      timestamp: DateTime.parse(json['timestamp']),
      isDownloaded: json['isDownloaded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'size': size,
      'type': type,
      'senderId': senderId,
      'timestamp': timestamp.toIso8601String(),
      'isDownloaded': isDownloaded,
    };
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  FileInfo copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    String? type,
    String? senderId,
    DateTime? timestamp,
    bool? isDownloaded,
  }) {
    return FileInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }
}
