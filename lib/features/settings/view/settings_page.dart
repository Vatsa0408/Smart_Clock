import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../charge_control/charge_control_bloc.dart';
import '../../diagnostics/diagnostics_bloc.dart';
import '../../now_playing/now_playing_bloc.dart';
import '../settings_bloc.dart';

/// Hidden settings. Closes itself after 2 minutes without a touch, so it never hides the clock.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Timer? _idle;

  void _restart() {
    _idle?.cancel();
    _idle = Timer(const Duration(minutes: 2), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void dispose() {
    _idle?.cancel();
    super.dispose();
  }

  static String _hm(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

  Future<int?> _pick(BuildContext context, int current) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    return t == null ? null : t.hour * 60 + t.minute;
  }

  static String _protectStatus(ChargeControlState c) => switch (c.status) {
    _ when !c.serviceEnabled => 'Enable the accessibility service',
    ProtectStatus.switching => 'Switching, the tablet restarts',
    ProtectStatus.failed => 'Change did not apply',
    ProtectStatus.serviceOff => 'Enable the accessibility service',
    _ => 'Accessibility service enabled',
  };

  Future<void> _fix(BuildContext context, bool on) async {
    final bloc = context.read<ChargeControlBloc>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        content: const Text('This restarts the tablet (about 1 min). Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Continue')),
        ],
      ),
    );
    if (ok == true) bloc.add(ChargeControlProtectWanted(on));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    return Listener(
      onPointerDown: (_) => _restart(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, s) => ListView(
            children: [
              const _Header('Night'),
              ListTile(
                title: const Text('Start'),
                trailing: Text(_hm(s.nightStartMin)),
                onTap: () async {
                  final m = await _pick(context, s.nightStartMin);
                  if (m != null) {
                    bloc.add(SettingsNightScheduleChanged(startMin: m));
                  }
                },
              ),
              ListTile(
                title: const Text('End'),
                trailing: Text(_hm(s.nightEndMin)),
                onTap: () async {
                  final m = await _pick(context, s.nightEndMin);
                  if (m != null) {
                    bloc.add(SettingsNightScheduleChanged(endMin: m));
                  }
                },
              ),
              ListTile(
                title: Text(
                  'Night brightness ${(s.nightBrightness * 100).round()}%',
                ),
                subtitle: Slider(
                  min: 0.02,
                  max: 0.5,
                  value: s.nightBrightness.clamp(0.02, 0.5),
                  onChanged: (v) =>
                      bloc.add(SettingsNightScheduleChanged(brightness: v)),
                ),
              ),
              const _Header('Battery'),
              ListTile(
                title: Text('Low battery warning at ${s.lowBatteryPct}%'),
                subtitle: Slider(
                  min: 5,
                  max: 50,
                  divisions: 45,
                  value: s.lowBatteryPct.toDouble().clamp(5, 50),
                  onChanged: (v) =>
                      bloc.add(SettingsLowBatteryChanged(v.round())),
                ),
              ),
              ListTile(
                title: Text('Overheat guard at ${s.overheatC.round()} °C'),
                subtitle: Slider(
                  min: 38,
                  max: 55,
                  divisions: 17,
                  value: s.overheatC.clamp(38.0, 55.0),
                  onChanged: (v) => bloc.add(SettingsOverheatChanged(v)),
                ),
              ),
              BlocBuilder<ChargeControlBloc, ChargeControlState>(
                builder: (context, c) => c.protectOn == null
                    ? const SizedBox.shrink() // Windows, or not read yet
                    : Column(
                        children: [
                          const _Header('Battery protection'),
                          SwitchListTile(
                            title: const Text('Keep Protect battery ON (holds charge at about 85%)'),
                            value: s.keepProtect,
                            onChanged: (v) => bloc.add(SettingsKeepProtectToggled(v)),
                          ),
                          ListTile(
                            title: Text('Protect battery is ${c.protectOn! ? 'ON' : 'OFF'}'),
                            subtitle: Text(_protectStatus(c)),
                            trailing: c.protectOn != s.keepProtect && c.status != ProtectStatus.switching
                                ? FilledButton(
                                    onPressed: () => _fix(context, s.keepProtect),
                                    child: Text(s.keepProtect ? 'Fix' : 'Turn off'),
                                  )
                                : null,
                          ),
                          ListTile(
                            title: const Text('Open Accessibility settings'),
                            onTap: () => context.read<ChargeControlBloc>().add(const ChargeControlAccessibilityOpened()),
                          ),
                        ],
                      ),
              ),
              const _Header('Display'),
              SwitchListTile(
                title: const Text('Burn-in orbit (shift picture 4 px every 5 min)'),
                value: s.burnInOrbit,
                onChanged: (v) => bloc.add(SettingsBurnInToggled(v)),
              ),
              if (Platform.isAndroid) ...[
                const _Header('Now playing'),
                BlocBuilder<NowPlayingBloc, NowPlayingState>(
                  builder: (context, n) => ListTile(
                    title: Text(switch (n.access) {
                      NowPlayingAccess.granted => 'Notification access granted',
                      NowPlayingAccess.unsupported => 'Not supported on this device',
                      _ => 'Grant notification access',
                    }),
                    onTap: n.access == NowPlayingAccess.denied || n.access == NowPlayingAccess.unknown
                        ? () => context.read<NowPlayingBloc>().add(const NowPlayingAccessRequested())
                        : null,
                  ),
                ),
                const _Header('System'),
                ListTile(
                  title: const Text('Choose home app (leave launcher mode)'),
                  onTap: () => bloc.add(const SettingsHomeAppPickerOpened()),
                ),
                ListTile(
                  title: const Text('Android settings'),
                  onTap: () => bloc.add(const SettingsAndroidSettingsOpened()),
                ),
              ],
              const _Header('Diagnostics'),
              BlocBuilder<DiagnosticsBloc, DiagnosticsState>(
                builder: (context, d) => ExpansionTile(
                  title: const Text('Log'),
                  onExpansionChanged: (open) {
                    if (open) {
                      context.read<DiagnosticsBloc>().add(const DiagnosticsOpened());
                    }
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SelectableText(
                        d.lines.isEmpty ? '(empty)' : d.lines.join('\n'),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.read<DiagnosticsBloc>().add(
                        const DiagnosticsCleared(),
                      ),
                      child: const Text('Clear log'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.primary),
    ),
  );
}
