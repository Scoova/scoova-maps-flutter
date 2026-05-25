# scoova_maps (Dart / Flutter)

Scoova map SDK for Dart and Flutter. Ships **static-map URL builders and a
Scoova-compatible style URL builder** — drop them into `Image.network(...)`,
`NetworkImage`, server-side renderers, OG share images, PDF receipts, or
feed them into your existing `maplibre_gl_flutter` map.

> A separate `scoova_maps_gl` package wrapping `maplibre_gl_flutter` is
> planned. Until it ships, use `maplibre_gl_flutter` directly and feed it
> the URLs returned by `styleUrl(...)`.

## Install

```yaml
dependencies:
  scoova_maps: ^1.0.0
```

## Static map URL

```dart
import 'package:flutter/material.dart';
import 'package:scoova_maps/scoova_maps.dart';

final url = staticMapUrl(StaticMapOptions(
  apiKey: 'sk_live_…',
  style: 'scoova-light',
  width: 600, height: 400,
  center: const ScoovaLatLng(lat: 30.0444, lon: 31.2357),
  zoom: 13,
  markers: const [
    StaticMapMarker(lat: 30.0444, lon: 31.2357, color: '#FF6A00'),
  ],
  paths: const [
    StaticMapPath(
      coordinates: [
        ScoovaLatLng(lat: 30.04, lon: 31.24),
        ScoovaLatLng(lat: 30.05, lon: 31.25),
        ScoovaLatLng(lat: 30.06, lon: 31.26),
      ],
      stroke: '#0EA5E9', width: 4,
    ),
  ],
  locale: 'fr',
));

Image.network(url, width: 300, height: 200);
```

Fetch the bytes directly (e.g. for offline caching):

```dart
final Uint8List bytes = await staticMapBytes(StaticMapOptions(...));
final img = Image.memory(bytes);
```

## Style URL

```dart
final styleUri = styleUrl('scoova-dark', const StyleUrlOptions(
  apiKey: 'sk_live_…',
  locale: 'es',
));
// Feed `styleUri` into your maplibre_gl_flutter MapLibreMap.
```

## API

### Pure URL builders
- `staticMapUrl(StaticMapOptions opts): String`
- `styleUrl(String styleName, StyleUrlOptions options): String`

### Async fetcher
- `staticMapBytes(StaticMapOptions opts, {http.Client? client}): Future<Uint8List>`

### Constants & types
- `ScoovaMapDefaults` (`apiBase`, `tilesBase`, `styleUrl`, `tilesUrl`,
  `defaultCenter`, `defaultZoom`, `attribution`, `styleUrlForLocale(...)`)
- `ScoovaColors`, `ScoovaLatLng`
- `StaticMapMarker`, `StaticMapPath`, `StaticMapOptions`, `StyleUrlOptions`
- `ScoovaMapsError`

## Tests

```
dart test
```
