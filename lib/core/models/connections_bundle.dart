import 'dart:convert';
import 'vpn_config.dart';
import '../services/config_storage_service.dart' show Subscription;

class ConnectionsBundle {
  static const int currentVersion = 1;

  final int version;
  final DateTime exportedAt;
  final String? label;
  final List<VpnConfig> configs;
  final List<Subscription> subscriptions;

  const ConnectionsBundle({
    this.version = currentVersion,
    required this.exportedAt,
    this.label,
    this.configs = const [],
    this.subscriptions = const [],
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt.toIso8601String(),
        if (label != null) 'label': label,
        'configs': configs.map((c) => c.toJson()).toList(),
        'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
      };

  factory ConnectionsBundle.fromJson(Map<String, dynamic> json) => ConnectionsBundle(
        version: json['version'] as int? ?? 1,
        exportedAt: DateTime.parse(json['exportedAt'] as String),
        label: json['label'] as String?,
        configs: (json['configs'] as List<dynamic>?)
            ?.map((e) => VpnConfig.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        subscriptions: (json['subscriptions'] as List<dynamic>?)
            ?.map((e) => Subscription.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      );

  String toBase64() {
    final bytes = utf8.encode(jsonEncode(toJson()));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static ConnectionsBundle fromBase64(String b64) {
    final padded = b64.padRight((b64.length + 3) ~/ 4 * 4, '=');
    final json = utf8.decode(base64Url.decode(padded));
    return ConnectionsBundle.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  String toDeeplink() => 'teapod://import/connections?data=${toBase64()}';
}
