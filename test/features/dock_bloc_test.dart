import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clock/features/dock/dock_bloc.dart';
import 'package:smart_clock/features/dock/dock_store.dart';

void main() {
  test('dock lists Spotify right after YouTube Music', () {
    final labels = DockBloc(const DockStore()).state.apps.map((a) => a.label);
    expect(labels, ['YouTube Music', 'Spotify', 'Google Home', 'Xiaomi Home']);
  });
}
