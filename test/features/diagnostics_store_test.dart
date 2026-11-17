import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/diagnostics/diagnostics_bloc.dart';
import 'package:smart_clock/features/diagnostics/diagnostics_store.dart';

class _MockStore extends Mock implements DiagnosticsStore {}

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('diag'));
  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('rotates past maxBytes, tail returns last lines in order, clear removes both', () async {
    final s = DiagnosticsStore(dir, maxBytes: 200);
    for (var i = 0; i < 50; i++) {
      s.write('I', 'line $i');
    }
    final log = File('${dir.path}${Platform.pathSeparator}app.log');
    expect(log.existsSync(), isTrue);
    expect(File('${log.path}.1').existsSync(), isTrue);
    expect(log.lengthSync(), lessThan(200 + 80));
    final t = await s.tail(5);
    expect(t.length, 5);
    expect(t.last, endsWith('line 49'));
    expect(t.first, endsWith('line 45'));
    await s.clear();
    expect(log.existsSync() || File('${log.path}.1').existsSync(), isFalse);
  });

  test('write into a deleted directory does not throw', () {
    final s = DiagnosticsStore(Directory('${dir.path}${Platform.pathSeparator}gone'));
    expect(() => s.write('E', 'x', StackTrace.current), returnsNormally);
  });

  blocTest<DiagnosticsBloc, DiagnosticsState>(
    'DiagnosticsOpened emits the stored lines',
    build: () {
      final m = _MockStore();
      when(() => m.tail()).thenAnswer((_) async => ['a', 'b']);
      return DiagnosticsBloc(m);
    },
    act: (b) => b.add(const DiagnosticsOpened()),
    expect: () => [const DiagnosticsState(lines: ['a', 'b'])],
  );
}
