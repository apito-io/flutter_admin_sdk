/// Connection lifecycle for the shared GraphQL subscription socket.
enum ApitoConnectionState { idle, connecting, connected, reconnecting, closed }

/// Signals that are not a single subscription payload.
class ApitoSubscriptionSignal {
  const ApitoSubscriptionSignal({this.resyncRequired = false});

  /// The socket reconnected or a live subscription was terminated.
  /// Generated watchers must run one authoritative HTTP refetch.
  /// Live events during the gap may have been missed. There is no replay.
  final bool resyncRequired;
}

enum ModelChangeKind { created, updated, deleted, unknown }

ModelChangeKind modelChangeKindFrom(String? raw) {
  switch (raw) {
    case 'CREATED':
      return ModelChangeKind.created;
    case 'UPDATED':
      return ModelChangeKind.updated;
    case 'DELETED':
      return ModelChangeKind.deleted;
    default:
      return ModelChangeKind.unknown;
  }
}

class ModelChangeEvent {
  const ModelChangeEvent({
    required this.event,
    required this.model,
    this.id,
    this.projectId,
    this.node,
    this.previousValues,
  });

  final ModelChangeKind event;
  final String model;
  final String? id;
  final String? projectId;
  final Map<String, dynamic>? node;
  final Map<String, dynamic>? previousValues;

  static ModelChangeEvent? fromPayload(Map<String, dynamic>? payload) {
    if (payload == null) return null;
    return ModelChangeEvent(
      event: modelChangeKindFrom(payload['event']?.toString()),
      model: payload['model']?.toString() ?? '',
      id: payload['id']?.toString(),
      projectId: payload['projectId']?.toString(),
      node: _asMap(payload['node']),
      previousValues: _asMap(payload['previousValues']),
    );
  }
}

class BroadcastMessage {
  const BroadcastMessage({
    required this.channel,
    required this.event,
    this.payload,
    this.at,
  });

  final String channel;
  final String event;
  final Map<String, dynamic>? payload;
  final String? at;

  static BroadcastMessage? fromPayload(Map<String, dynamic>? payload) {
    if (payload == null) return null;
    return BroadcastMessage(
      channel: payload['channel']?.toString() ?? '',
      event: payload['event']?.toString() ?? '',
      payload: _asMap(payload['payload']),
      at: payload['at']?.toString(),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

/// Subscription documents return the stored document (`id` + `data`), while
/// generated model classes expect the flat field map used by list queries.
Map<String, dynamic> flattenModelNode(Map<String, dynamic> node) {
  final data = node['data'];
  if (data is Map) {
    return {
      ...Map<String, dynamic>.from(data),
      'id': (node['id'] ?? data['id'])?.toString() ?? '',
    };
  }
  return Map<String, dynamic>.from(node);
}
