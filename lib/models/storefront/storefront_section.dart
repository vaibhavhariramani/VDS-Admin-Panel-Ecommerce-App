import 'section_config.dart';

/// One entry in a storefront's `homepage` list: which predefined section,
/// where it sits, whether it's shown, and its typed config. This is the
/// exact JSON shape the Client App reads and maps `type -> Widget`.
class StorefrontSection {
  final String id;
  final String type;
  final int order;
  final bool enabled;
  final SectionConfig config;

  const StorefrontSection({
    required this.id,
    required this.type,
    required this.order,
    required this.enabled,
    required this.config,
  });

  StorefrontSection copyWith({
    int? order,
    bool? enabled,
    SectionConfig? config,
  }) =>
      StorefrontSection(
        id: id,
        type: type,
        order: order ?? this.order,
        enabled: enabled ?? this.enabled,
        config: config ?? this.config,
      );

  factory StorefrontSection.fromJson(Map<String, dynamic> json) {
    final String type = json['type']?.toString() ?? '';
    final SectionTypeInfo? info = sectionTypeRegistry[type];
    final Map<String, dynamic> configJson =
        (json['config'] as Map<String, dynamic>?) ?? const {};
    return StorefrontSection(
      id: json['id']?.toString() ?? '',
      type: type,
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
      enabled: json['enabled'] is bool ? json['enabled'] as bool : true,
      config: info != null ? info.fromJson(configJson) : const _UnknownSectionConfig(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'order': order,
        'enabled': enabled,
        'config': config.toJson(),
      };

  static StorefrontSection create(String type) {
    final SectionTypeInfo? info = sectionTypeRegistry[type];
    return StorefrontSection(
      id: 'sec_${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      order: 0,
      enabled: true,
      config: info?.defaultConfig() ?? const _UnknownSectionConfig(),
    );
  }
}

/// Falls back safely if a `type` isn't in the registry (e.g. a newer admin
/// version wrote a section type this build doesn't know about yet) instead
/// of throwing while loading the draft/published document.
class _UnknownSectionConfig extends SectionConfig {
  const _UnknownSectionConfig();
  @override
  Map<String, dynamic> toJson() => const {};
}
