/// Pre-login project runtime for one platform (`android`, `ios`, or `web`).
///
/// Extras are one-key objects, for example `[{ "min_corridor_m": "50" }]`.
class ClientRuntime {
  const ClientRuntime({
    required this.platform,
    required this.minVersionName,
    required this.minBuildNumber,
    required this.forceUpdate,
    required this.storeUrl,
    required this.messageEn,
    required this.messageBn,
    required this.maintenance,
    required this.maintenanceHours,
    this.extras = const [],
  });

  final String platform;
  final String minVersionName;
  final int minBuildNumber;
  final bool forceUpdate;
  final String storeUrl;
  final String messageEn;
  final String messageBn;
  final bool maintenance;
  final int maintenanceHours;
  final List<Map<String, String>> extras;

  factory ClientRuntime.fromGraphql(
    Map<dynamic, dynamic> raw, {
    required String platform,
  }) {
    final version = _text(raw['min_version_name']);
    return ClientRuntime(
      platform: _text(raw['platform']).isEmpty ? platform : _text(raw['platform']),
      minVersionName: version.isEmpty ? '0.0.0' : version,
      minBuildNumber: _int(raw['min_build_number']),
      forceUpdate: raw['force_update'] == true,
      storeUrl: _text(raw['store_url']),
      messageEn: _text(raw['message_en']),
      messageBn: _text(raw['message_bn']),
      maintenance: raw['maintenance'] == true,
      maintenanceHours: _int(raw['maintenance_hours']),
      extras: _extras(raw['extras']),
    );
  }

  static String _text(Object? value) => value?.toString().trim() ?? '';

  static int _int(Object? value) {
    if (value is int) return value < 0 ? 0 : value;
    if (value is num) return value.toInt() < 0 ? 0 : value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<Map<String, String>> _extras(Object? raw) {
    if (raw is! List) return const [];
    final out = <Map<String, String>>[];
    for (final item in raw) {
      if (item is! Map || item.length != 1) continue;
      final key = item.keys.first.toString();
      out.add({key: item.values.first?.toString() ?? ''});
    }
    return out;
  }
}
