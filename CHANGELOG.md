# Changelog

All notable changes to `scoova_maps` (pub.dev) are documented here.
Follows [Semantic Versioning](https://semver.org/).

## 1.0.0 — 2026-05-25

Initial release.

### Added
- `staticMapUrl(opts)` — pure URL builder for the static-map endpoint, ready
  to feed into `Image.network(...)` or `NetworkImage(...)`.
- `staticMapBytes(opts, {client})` — `Future<Uint8List>` that fetches the
  rendered PNG; forwards `Accept-Language` when a locale is supplied;
  accepts an injectable `http.Client` for tests.
- `styleUrl(styleName, options)` — MapLibre-compatible style URL builder.
- `ScoovaMapDefaults` — endpoint constants + `styleUrlForLocale(locale)`.
- `ScoovaColors`, `ScoovaLatLng`, `StaticMapMarker`, `StaticMapPath`,
  `StaticMapOptions`, `StyleUrlOptions`, `ScoovaMapsError`.
- LICENSE (Apache-2.0), README, CHANGELOG, `.gitignore`.

### Not included
- A wrapper around `maplibre_gl_flutter` (renamed `flutter_maplibre_gl` in
  some forks) is intentionally **not** in this package — it'll ship as
  `scoova_maps_gl` so callers who only need URL builders don't pull in
  the native GL dependency. In the meantime, use `maplibre_gl_flutter`
  directly with the URLs returned by `styleUrl(...)`.
