import 'dart:typed_data';

import 'package:pointycastle/export.dart';

typedef MiValues = ({String mac, double? temperature, double? humidity});

/// Parses MiBeacon service data (UUID 0xFE95) from a Xiaomi BLE thermometer.
/// [keys] maps the sensor MAC ('A4:C1:38:..') to its 16-byte bindkey.
/// Returns null for frames that are not decodable (no key, wrong key, other object).
MiValues? parseMiBeacon(Uint8List d, Map<String, Uint8List> keys) {
  if (d.length < 5) return null;
  final fc = d[0] | d[1] << 8;
  final version = fc >> 12;
  if (fc & 0x80 != 0 || fc & 0x40 == 0 || fc & 0x10 == 0 || version < 2) {
    return null; // mesh, no object, or no MAC in frame
  }
  if (d.length < 11) return null;
  final mac = _fmt(d.sublist(5, 11).reversed);
  var i = 11;
  if (fc & 0x20 != 0) {
    // capability byte (+ IO bytes when its 0x20 bit is set)
    if (d.length <= i) return null;
    if (d[i] & 0x20 != 0) i++;
    i++;
  }

  var p = d.sublist(i);
  if (fc & 0x08 != 0) {
    final key = keys[mac];
    if (key == null || version < 4 || d.length < i + 9) return null;
    final nonce = Uint8List.fromList([
      ...[for (final s in mac.split(':')) int.parse(s, radix: 16)].reversed,
      ...d.sublist(2, 5),
      ...d.sublist(d.length - 7, d.length - 4),
    ]);
    final ccm = CCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), 32, nonce, Uint8List.fromList([0x11])));
    try {
      p = ccm.process(Uint8List.fromList(
          [...d.sublist(i, d.length - 7), ...d.sublist(d.length - 4)]));
    } catch (_) {
      return null; // wrong key or corrupt frame
    }
  }

  double? t, h;
  for (var j = 0; j + 3 <= p.length;) {
    final type = p[j] | p[j + 1] << 8, len = p[j + 2];
    j += 3;
    if (j + len > p.length) break;
    final v = ByteData.sublistView(p, j, j + len);
    j += len;
    switch (type) {
      case 0x1004 when len == 2:
        t = v.getInt16(0, Endian.little) / 10;
      case 0x1006 when len == 2:
        h = v.getUint16(0, Endian.little) / 10;
      case 0x100D when len == 4:
        t = v.getInt16(0, Endian.little) / 10;
        h = v.getUint16(2, Endian.little) / 10;
    }
  }
  if (t == null && h == null) return null;
  return (mac: mac, temperature: t, humidity: h);
}

String _fmt(Iterable<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();

Uint8List hexKey(String hex) => Uint8List.fromList(
    [for (var k = 0; k < hex.length; k += 2) int.parse(hex.substring(k, k + 2), radix: 16)]);
