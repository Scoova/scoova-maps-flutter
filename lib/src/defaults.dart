// Copyright 2026 Scoova
// Licensed under the Apache License, Version 2.0.

/// Canonical Scoova endpoint defaults — kept identical across web, Android,
/// React Native, iOS, and Flutter.
class ScoovaMapDefaults {
  ScoovaMapDefaults._();

  /// API gateway base, used for static map renders.
  static const String apiBase = 'https://api.scoo-va.info/api/v1';

  /// Tileserver base, used for live MapLibre style URLs.
  static const String tilesBase = 'https://tiles.scoo-va.info';

  /// Canonical Scoova default style (no locale, no API key).
  static const String styleUrl = 'https://tiles.scoo-va.info/style.json';

  /// MVT tile URL template, useful when constructing an inline style.
  static const String tilesUrl = 'https://tiles.scoo-va.info/v1/{z}/{x}/{y}.mvt';

  /// Cairo, Egypt — Scoova's launch city.
  static const ScoovaLatLng defaultCenter =
      ScoovaLatLng(lat: 30.0444, lon: 31.2357);

  static const double defaultZoom = 12;
  static const double minZoom = 0;
  static const double maxZoom = 22;
  static const String attribution = '© Scoova · OpenStreetMap contributors';
  static const ScoovaColors colors = ScoovaColors();

  /// Returns [styleUrl] with `?locale=<locale>` appended. Feed the result
  /// to a live MapLibre map so place labels render in the caller's locale.
  static String styleUrlForLocale(String locale) {
    if (locale.isEmpty) return styleUrl;
    return '$styleUrl?locale=${Uri.encodeQueryComponent(locale)}';
  }
}

/// Geographic point.
class ScoovaLatLng {
  final double lat;
  final double lon;
  const ScoovaLatLng({required this.lat, required this.lon});

  @override
  bool operator ==(Object other) =>
      other is ScoovaLatLng && other.lat == lat && other.lon == lon;
  @override
  int get hashCode => Object.hash(lat, lon);

  @override
  String toString() => 'ScoovaLatLng($lat, $lon)';
}

/// Scoova brand colours for routes / markers.
class ScoovaColors {
  final String routePrimary;
  final String routeCasing;
  final String routeAlternate;
  final String routeProgress;
  final String markerFill;
  final String markerStroke;
  const ScoovaColors({
    this.routePrimary = '#0EA5E9',
    this.routeCasing = '#0369A1',
    this.routeAlternate = '#94A3B8',
    this.routeProgress = '#10B981',
    this.markerFill = '#0EA5E9',
    this.markerStroke = '#FFFFFF',
  });
}
