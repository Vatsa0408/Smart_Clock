import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clock/features/sensor/mibeacon.dart';

void main() {
  // LYWSD03MMC encrypted MiBeacon v5 vector from Bluetooth-Devices/xiaomi-ble.
  final data = Uint8List.fromList([
    0x58, 0x58, 0x5B, 0x05, 0x50, 0xF4, 0x83, 0x02, 0x38, 0xC1, 0xA4,
    0x95, 0xEF, 0x58, 0x76, 0x3C, 0x26, 0x00, 0x00, 0x97, 0xE2, 0xAB, 0xB5,
  ]);
  const mac = 'A4:C1:38:02:83:F4';

  test('decrypts LYWSD03MMC MiBeacon v5', () {
    final v = parseMiBeacon(data, {mac: hexKey('e9ea895fac7cca6d30532432a516f3a8')});
    expect(v!.mac, mac);
    expect(v.humidity!.truncate(), 46);
  });

  test('wrong key or missing key yields null', () {
    expect(parseMiBeacon(data, {mac: hexKey('00' * 16)}), isNull);
    expect(parseMiBeacon(data, {}), isNull);
  });
}
