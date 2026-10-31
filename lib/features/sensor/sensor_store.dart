import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:universal_ble/universal_ble.dart';

import 'mibeacon.dart';

const roomNames = ['Living Room', 'Bedroom', 'Bathroom'];

typedef SensorConfig = ({String mac, String key});

final class RoomSensor extends Equatable {
  const RoomSensor(this.name,
      {this.mac = '', this.key = '', this.temperature, this.humidity, this.seenAt});

  final String name;
  final String mac; // 'A4:C1:38:..' upper-case, empty if not configured
  final String key; // 32 hex chars; never persisted
  final double? temperature;
  final double? humidity;
  final DateTime? seenAt;

  bool get configured => mac.isNotEmpty && key.isNotEmpty;

  RoomSensor withConfig(SensorConfig? c) => RoomSensor(name,
      mac: c?.mac ?? '',
      key: c?.key ?? '',
      temperature: temperature,
      humidity: humidity,
      seenAt: seenAt);

  RoomSensor merge(MiValues v) => RoomSensor(name,
      mac: mac,
      key: key,
      temperature: v.temperature ?? temperature,
      humidity: v.humidity ?? humidity,
      seenAt: DateTime.now());

  /// Persists readings only; the bindkey stays in the local config file.
  Map<String, Object?> toJson() =>
      {'name': name, 't': temperature, 'h': humidity, 'seen': seenAt?.toIso8601String()};

  factory RoomSensor.fromJson(Map<String, dynamic> j) => RoomSensor(j['name'] as String,
      temperature: (j['t'] as num?)?.toDouble(),
      humidity: (j['h'] as num?)?.toDouble(),
      seenAt: DateTime.tryParse(j['seen'] as String? ?? ''));

  @override
  List<Object?> get props => [name, mac, key, temperature, humidity, seenAt];
}

/// Source of room sensor readings. Swap in e.g. a Home Assistant store later.
abstract interface class SensorStore {
  /// Room name -> MAC and bindkey. Empty when nothing is configured.
  Future<Map<String, SensorConfig>> loadConfig();

  /// Emits decoded values for the given MAC -> bindkey map until cancelled.
  Stream<MiValues> watch(Map<String, Uint8List> keys);
}

final _macRe = RegExp(r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$');
final _keyRe = RegExp(r'^[0-9a-fA-F]{32}$');

/// Passive BLE scan of Xiaomi MiBeacon advertisements, decrypted with bindkeys
/// from the gitignored asset `assets/config/sensors.json`.
class BleSensorStore implements SensorStore {
  const BleSensorStore();

  @override
  Future<Map<String, SensorConfig>> loadConfig() async {
    try {
      final j = jsonDecode(await rootBundle.loadString('assets/config/sensors.json'))
          as Map<String, dynamic>;
      return {
        for (final MapEntry(key: room, value: c) in j.entries)
          if (c is Map &&
              _macRe.hasMatch('${c['mac']}'.toUpperCase()) &&
              _keyRe.hasMatch('${c['key']}'))
            room: (mac: '${c['mac']}'.toUpperCase(), key: '${c['key']}'),
      };
    } catch (_) {
      return {}; // file missing or malformed -> cards show "--"
    }
  }

  @override
  Stream<MiValues> watch(Map<String, Uint8List> keys) {
    final c = StreamController<MiValues>();
    c.onListen = () async {
      try {
        await UniversalBle.requestPermissions();
        UniversalBle.onScanResult = (dev) {
          for (final MapEntry(:key, :value) in dev.serviceData.entries) {
            if (!key.toLowerCase().contains('fe95')) continue;
            final v = parseMiBeacon(value, keys);
            if (v != null && keys.containsKey(v.mac)) c.add(v);
          }
        };
        // One long scan, no start/stop cycling (Android throttles >5 starts per 30 s).
        // ponytail: Android may turn scans >30 min opportunistic; add a 25 min
        // stop/start timer here if readings stop on the tablet.
        await UniversalBle.startScan();
      } catch (e) {
        c.addError(e);
      }
    };
    c.onCancel = () async {
      UniversalBle.onScanResult = null;
      try {
        await UniversalBle.stopScan();
      } catch (_) {}
    };
    return c.stream;
  }
}

/// For tests and machines without Bluetooth.
class SampleSensorStore implements SensorStore {
  const SampleSensorStore();

  @override
  Future<Map<String, SensorConfig>> loadConfig() async => {
        for (final (i, n) in roomNames.indexed)
          n: (mac: 'A4:C1:38:00:00:0$i', key: '00' * 16),
      };

  @override
  Stream<MiValues> watch(Map<String, Uint8List> keys) => Stream.fromIterable([
        for (final mac in keys.keys) (mac: mac, temperature: 22.4, humidity: 48.0),
      ]);
}
