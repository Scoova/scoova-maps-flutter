// Copyright 2026 Scoova
// Licensed under the Apache License, Version 2.0.
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scoova_maps/scoova_maps.dart';
import 'package:test/test.dart';

void main() {
  group('ScoovaMapDefaults', () {
    test('endpoints point at scoo-va.info', () {
      expect(ScoovaMapDefaults.apiBase, 'https://api.scoo-va.info/api/v1');
      expect(ScoovaMapDefaults.tilesBase, 'https://tiles.scoo-va.info');
      expect(ScoovaMapDefaults.styleUrl, 'https://tiles.scoo-va.info/style.json');
      expect(ScoovaMapDefaults.defaultCenter.lat, closeTo(30.0444, 1e-6));
      expect(ScoovaMapDefaults.defaultCenter.lon, closeTo(31.2357, 1e-6));
    });

    test('styleUrlForLocale appends ?locale=… or returns plain', () {
      expect(ScoovaMapDefaults.styleUrlForLocale(''), ScoovaMapDefaults.styleUrl);
      expect(
        ScoovaMapDefaults.styleUrlForLocale('fr'),
        '${ScoovaMapDefaults.styleUrl}?locale=fr',
      );
    });
  });

  group('staticMapUrl', () {
    test('explicit-center URL points at the gateway', () {
      final url = staticMapUrl(StaticMapOptions(
        style: 'scoova-light', width: 600, height: 400,
        center: const ScoovaLatLng(lat: 30.0444, lon: 31.2357), zoom: 13,
        apiKey: 'k123',
      ));
      expect(url.startsWith('${ScoovaMapDefaults.apiBase}/staticmap/scoova-light/static/'), isTrue);
      expect(url, contains('/static/31.2357,30.0444,13.0/'));
      expect(url, contains('600x400.png'));
      expect(url, contains('api_key=k123'));
    });

    test('uses /auto/ when no centre is supplied', () {
      final url = staticMapUrl(StaticMapOptions(
        style: 'scoova-dark', width: 100, height: 100,
        markers: const [StaticMapMarker(lat: 30, lon: 31)],
        apiKey: 'k',
      ));
      expect(url, contains('/static/auto/'));
    });

    test('serialises markers with colour + icon', () {
      final url = staticMapUrl(StaticMapOptions(
        style: 's', width: 1, height: 1,
        markers: const [StaticMapMarker(lat: 30, lon: 31, color: '#FF6A00', icon: 'pin')],
        apiKey: 'k',
      ));
      expect(url, contains('marker=color:%23FF6A00|icon:pin|30.0,31.0'));
    });

    test('drops paths with fewer than two coords; serialises the others', () {
      final url = staticMapUrl(StaticMapOptions(
        style: 's', width: 1, height: 1,
        paths: const [
          StaticMapPath(
            coordinates: [
              ScoovaLatLng(lat: 30, lon: 31),
              ScoovaLatLng(lat: 31, lon: 32),
            ],
            stroke: '#0EA5E9', width: 4,
          ),
          StaticMapPath(coordinates: [ScoovaLatLng(lat: 0, lon: 0)]),
        ],
        apiKey: 'k',
      ));
      expect(url, contains('path=stroke:%230EA5E9|width:4|30.0,31.0|31.0,32.0'));
      expect('path='.allMatches(url).length, 1);
    });

    test('forwards locale and respects apiBase override', () {
      final url = staticMapUrl(StaticMapOptions(
        style: 's', width: 1, height: 1, apiKey: 'k',
        locale: 'ar-EG',
        apiBase: 'https://gateway.example.test/api/v1/',
      ));
      expect(url, contains('locale=ar-EG'));
      expect(url.startsWith('https://gateway.example.test/api/v1/staticmap/'), isTrue);
    });
  });

  group('staticMapBytes (MockClient)', () {
    test('forwards Accept-Language and returns the bytes', () async {
      late http.Request capturedRequest;
      final client = MockClient((req) async {
        capturedRequest = req;
        return http.Response.bytes(
          [1, 2, 3, 4],
          200,
          headers: {'content-type': 'image/png'},
        );
      });

      final bytes = await staticMapBytes(
        StaticMapOptions(
          style: 's', width: 1, height: 1, apiKey: 'k', locale: 'fr',
        ),
        client: client,
      );
      expect(bytes, isA<Uint8List>());
      expect(bytes, equals([1, 2, 3, 4]));
      expect(capturedRequest.headers['Accept-Language'], 'fr');
    });

    test('throws ScoovaMapsError on non-2xx', () async {
      final client = MockClient((_) async => http.Response('forbidden', 403));
      await expectLater(
        staticMapBytes(
          StaticMapOptions(style: 's', width: 1, height: 1, apiKey: 'k'),
          client: client,
        ),
        throwsA(isA<ScoovaMapsError>()
            .having((e) => e.statusCode, 'statusCode', 403)),
      );
    });
  });

  group('styleUrl', () {
    test('points at tiles.scoo-va.info by default', () {
      final url = styleUrl('scoova-light', const StyleUrlOptions(apiKey: 'k'));
      expect(url.startsWith('${ScoovaMapDefaults.tilesBase}/styles/scoova-light/style.json?'), isTrue);
      expect(url, contains('api_key=k'));
    });

    test('forwards locale + tilesBase override', () {
      final url = styleUrl('scoova-dark', const StyleUrlOptions(
        apiKey: 'k', tilesBase: 'https://my-tiles.example.test/', locale: 'pt-BR',
      ));
      expect(url.startsWith('https://my-tiles.example.test/styles/scoova-dark/style.json?'), isTrue);
      expect(url, contains('locale=pt-BR'));
    });
  });

  test('UTF-8 sanity (unused but pins package_test loader)', () {
    expect(utf8.encode('Scoova').length, 6);
  });
}
