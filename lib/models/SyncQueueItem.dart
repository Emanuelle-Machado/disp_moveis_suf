class SyncQueueItem {
  final int? id;
  final String resource;
  final String action;
  final String data;
  final String timestamp;

  SyncQueueItem({
    this.id,
    required this.resource,
    required this.action,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'resource': resource,
    'action': action,
    'data': data,
    'timestamp': timestamp,
  };
}
