import 'dart:io';

/// Rolling on-device log: `app.log` rotates to `app.log.1` past [maxBytes].
class DiagnosticsStore {
  DiagnosticsStore(Directory dir, {this.maxBytes = 512 * 1024})
      : _file = File('${dir.path}${Platform.pathSeparator}app.log');
  final File _file;
  final int maxBytes;

  /// Synchronous and never throws: logging must not crash the clock.
  void write(String level, Object message, [StackTrace? stack]) {
    try {
      if (_file.existsSync() && _file.lengthSync() > maxBytes) {
        final old = File('${_file.path}.1');
        if (old.existsSync()) old.deleteSync();
        _file.renameSync(old.path);
      }
      // Keep the trace header: `flutter symbolize` needs it for obfuscated builds.
      final trace = stack == null ? '' : '\n${stack.toString().split('\n').take(40).join('\n')}';
      _file.writeAsStringSync('${DateTime.now().toIso8601String()} $level $message$trace\n',
          mode: FileMode.append);
    } catch (_) {}
  }

  Future<List<String>> tail([int n = 100]) async {
    final lines = [
      for (final f in [File('${_file.path}.1'), _file])
        if (await f.exists()) ...(await f.readAsLines()),
    ];
    return lines.length <= n ? lines : lines.sublist(lines.length - n);
  }

  Future<void> clear() async {
    for (final f in [File('${_file.path}.1'), _file]) {
      if (await f.exists()) await f.delete();
    }
  }
}
