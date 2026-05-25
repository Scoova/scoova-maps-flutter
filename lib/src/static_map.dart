// Copyright 2026 Scoova
// Licensed under the Apache License, Version 2.0.
//
// Static-map URL helpers + a `Uint8List` PNG fetcher. Pure Dart; works in
// Flutter, server-side, and CLI. No native dependencies.
//
// Gateway:
//   static map  -> https://api.scoo-va.info/api/v1/staticmap/{style}/static/{center}/{w}x{h}.png?...
//   style URL   -> https://tiles.scoo-va.info/styles/{style}/style.json?...
//
// Locale: the gateway honours `?locale=` and `Accept-Language`. We always
// append `?locale=` when supplied so `Image.network` (no header surface)
// works.

import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'defaults.dart';

class StaticMapMarker {
  final double lat;
  final double lon;

  /// Hex (`#FF6A00`) or named colour (`red`).
  final String? color;

  /// Built-in icon name, e.g. `pin`, `flag`.
  final String? icon;

  const StaticMapMarker({
    required this.lat,
    required this.lon,
    this.color,
    this.icon,
  });
}

class StaticMapPath {
  final List<ScoovaLatLng> coordinates;
  final String? stroke;
  final int? width;
  const StaticMapPath({
    required this.coordinates,
    this.stroke,
    this.width,
  });
}

class StaticMapOptions {
  /// Style name, e.g. `scoova-light`, `scoova-dark`, `scoova-satellite`.
  final String style;

  /// Image width in pixels.
  final int width;

  /// Image height in pixels.
  final int height;

  /// Image centre. Omit (and [zoom]) to auto-fit markers/paths.
  final ScoovaLatLng? center;

  /// Zoom level. Required when [center] is set; ignored otherwise.
  final double? zoom;

  /// Padding in pixels when auto-fitting markers/paths.
  final int? padding;

  final List<StaticMapMarker> markers;
  final List<StaticMapPath> paths;

  /// API key — appended as `?api_key=...` (works for `Image.network`).
  final String apiKey;

  /// Override the API base, default [ScoovaMapDefaults.apiBase].
  final String apiBase;

  /// BCP-47 locale (`en`, `fr`, `ar-EG`, ...). Forwarded to the gateway.
  final String? locale;

  const StaticMapOptions({
    required this.style,
    required this.width,
    required this.height,
    required this.apiKey,
    this.center,
    this.zoom,
    this.padding,
    this.markers = const [],
    this.paths = const [],
    this.apiBase = ScoovaMapDefaults.apiBase,
    this.locale,
  });
}

class StyleUrlOptions {
  final String apiKey;
  final String tilesBase;
  final String? locale;
  const StyleUrlOptions({
    required this.apiKey,
    this.tilesBase = ScoovaMapDefaults.tilesBase,
    this.locale,
  });
}

class ScoovaMapsError implements Exception {
  final int? statusCode;
  final String message;
  const ScoovaMapsError(this.message, {this.statusCode});
  @override
  String toString() =>
      statusCode == null ? 'ScoovaMapsError: $message' : 'ScoovaMapsError($statusCode): $message';
}

/// Pure URL builder for the static-map endpoint. No network.
String staticMapUrl(StaticMapOptions opts) {
  final base = _stripTrailingSlashes(opts.apiBase);
  final parts = <String>[];
  if (opts.padding != null) parts.add('padding=${opts.padding}');
  for (final m in opts.markers) {
    final tokens = <String>[];
    if (m.color != null) tokens.add('color:${m.color!.replaceAll('#', '%23')}');
    if (m.icon != null) tokens.add('icon:${Uri.encodeComponent(m.icon!)}');
    tokens.add('${m.lat},${m.lon}');
    parts.add('marker=${tokens.join('|')}');
  }
  for (final p in opts.paths) {
    if (p.coordinates.length < 2) continue;
    final tokens = <String>[];
    if (p.stroke != null) tokens.add('stroke:${p.stroke!.replaceAll('#', '%23')}');
    if (p.width != null) tokens.add('width:${p.width}');
    for (final c in p.coordinates) {
      tokens.add('${c.lat},${c.lon}');
    }
    parts.add('path=${tokens.join('|')}');
  }
  if (opts.locale != null) {
    parts.add('locale=${Uri.encodeQueryComponent(opts.locale!)}');
  }
  parts.add('api_key=${Uri.encodeQueryComponent(opts.apiKey)}');

  final size = '${opts.width}x${opts.height}';
  final centerSeg = (opts.center != null && opts.zoom != null)
      ? '${opts.center!.lon},${opts.center!.lat},${opts.zoom}'
      : 'auto';
  return '$base/staticmap/${Uri.encodeComponent(opts.style)}/static/$centerSeg/$size.png?${parts.join('&')}';
}

/// Fetch the rendered PNG and return its raw bytes. Forwards
/// `Accept-Language` when [StaticMapOptions.locale] is supplied. Throws
/// [ScoovaMapsError] on non-2xx responses. Pass a custom [client] to inject
/// a `MockClient` in tests.
Future<Uint8List> staticMapBytes(
  StaticMapOptions opts, {
  http.Client? client,
}) async {
  final ownClient = client == null;
  final c = client ?? http.Client();
  try {
    final headers = <String, String>{};
    if (opts.locale != null) headers['Accept-Language'] = opts.locale!;
    final res = await c.get(Uri.parse(staticMapUrl(opts)), headers: headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ScoovaMapsError(
        'staticMap: HTTP ${res.statusCode} ${res.reasonPhrase ?? ''}'.trim(),
        statusCode: res.statusCode,
      );
    }
    return res.bodyBytes;
  } finally {
    if (ownClient) c.close();
  }
}

/// Scoova-compatible style URL. Drop into a MapLibre map's `styleString`
/// or `styleURI` parameter.
String styleUrl(String styleName, StyleUrlOptions options) {
  final base = _stripTrailingSlashes(options.tilesBase);
  final parts = <String>['api_key=${Uri.encodeQueryComponent(options.apiKey)}'];
  if (options.locale != null) {
    parts.add('locale=${Uri.encodeQueryComponent(options.locale!)}');
  }
  return '$base/styles/${Uri.encodeComponent(styleName)}/style.json?${parts.join('&')}';
}

String _stripTrailingSlashes(String s) {
  var out = s;
  while (out.endsWith('/')) {
    out = out.substring(0, out.length - 1);
  }
  return out;
}
