import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../../clock/clock_bloc.dart';
import '../alarms_bloc.dart';
import '../alarms_store.dart';

/// "Alarms" / "New alarm" / "Edit alarm".
class AlarmsTitle extends StatelessWidget {
  const AlarmsTitle({super.key});

  @override
  Widget build(BuildContext context) => BlocSelector<AlarmsBloc, AlarmsState, Alarm?>(
        selector: (s) => s.editing,
        builder: (_, d) => Text(
          d == null ? 'Alarms' : (d.id == null ? 'New alarm' : 'Edit alarm'),
          style: flex(36, 600, Colors.white, em: -.01),
        ),
      );
}

/// New alarm (list) or Delete / Preview / Save (editor).
class AlarmsActions extends StatelessWidget {
  const AlarmsActions({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AlarmsBloc>();
    return BlocBuilder<AlarmsBloc, AlarmsState>(
      buildWhen: (a, b) => (a.editing == null) != (b.editing == null) || a.editing?.id != b.editing?.id || a.alarms.length != b.alarms.length,
      builder: (_, s) {
        final d = s.editing;
        if (d == null) {
          if (s.alarms.length >= AlarmsState.maxAlarms) return const SizedBox.shrink();
          return Btn(
            onTap: () => bloc.add(const AlarmEditStarted()),
            bg: kPrimary,
            fg: kOnPrimary,
            size: 22,
            height: 56,
            padding: const EdgeInsets.fromLTRB(20, 0, 28, 0),
            child: const Row(children: [Icon(Icons.add, size: 26), SizedBox(width: 10), Text('New alarm')]),
          );
        }
        return Row(
          children: [
            if (d.id != null) ...[
              Btn(
                onTap: () => bloc.add(const AlarmDeleted()),
                bg: const Color(0xFF8C1D18),
                fg: const Color(0xFFFFDAD6),
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const Text('Delete'),
              ),
              const SizedBox(width: 12),
            ],
            Btn(
              onTap: () => bloc.add(const AlarmPreviewed()),
              bg: kSecondary,
              fg: kOnSecondary,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text('Preview'),
            ),
            const SizedBox(width: 12),
            Btn(
              onTap: () => bloc.add(const AlarmSaved()),
              bg: kPrimary,
              fg: kOnPrimary,
              size: 22,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class AlarmsPanel extends StatelessWidget {
  const AlarmsPanel({super.key});

  @override
  Widget build(BuildContext context) => BlocSelector<AlarmsBloc, AlarmsState, bool>(
        selector: (s) => s.editing != null,
        builder: (_, editing) => editing ? const _Editor() : const _List(),
      );
}

class _List extends StatelessWidget {
  const _List();

  @override
  Widget build(BuildContext context) {
    final hour24 = context.select((ClockBloc b) => b.state.hour24);
    final alarms = context.select((AlarmsBloc b) => b.state.alarms);
    final bloc = context.read<AlarmsBloc>();
    if (alarms.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 40, 8, 0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text('No alarms yet. Tap New alarm to add one.', style: flex(26, 400, kMuted)),
        ),
      );
    }
    return ListView(
      children: [
        for (final a in alarms)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 104,
              padding: const EdgeInsets.only(left: 8, right: 28),
              decoration: BoxDecoration(color: kSurfaceHi, borderRadius: BorderRadius.circular(36)),
              child: Row(
                children: [
                  Expanded(
                    child: Opacity(
                      opacity: a.on ? 1 : .55,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(32),
                        onTap: () => bloc.add(AlarmEditStarted(a)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: hour24 ? 190 : 270,
                                child: Text(
                                  hm(a.h, a.m, hour24),
                                  style: flex(60, 600, Colors.white, em: -.03, height: 1, tabular: true),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(a.label, style: flex(26, 600, kText, height: 1)),
                                        const SizedBox(width: 18),
                                        for (final (i, l) in dayLetter.indexed)
                                          Container(
                                            width: 28,
                                            height: 28,
                                            margin: const EdgeInsets.only(right: 6),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: !a.noDays && a.days[i] ? kPrimary : kSurface,
                                            ),
                                            child: Text(
                                              l,
                                              style: flex(14, 700, !a.noDays && a.days[i] ? kOnPrimary : kMuted),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(a.summary,
                                        style: flex(19, 500, kMuted, height: 1.1),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Toggle(on: a.on, label: 'Alarm ${a.label} on or off', onTap: () => bloc.add(AlarmToggled(a.id!))),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Editor extends StatefulWidget {
  const _Editor();

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late final _label = TextEditingController(text: context.read<AlarmsBloc>().state.editing?.label);

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  InputDecoration _field(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: flex(28, 500, kOutline),
        filled: true,
        fillColor: kSurfaceHi,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 28),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(34), borderSide: const BorderSide(color: kSecondary, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(34), borderSide: const BorderSide(color: kPrimary, width: 3)),
      );

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AlarmsBloc>();
    final hour24 = context.select((ClockBloc b) => b.state.hour24);
    final d = context.select((AlarmsBloc b) => b.state.editing);
    if (d == null) return const SizedBox.shrink();
    void upd(Alarm a) => bloc.add(AlarmDraftChanged(a));

    Widget seg(String label, bool on, VoidCallback tap, {double size = 21, double? h = 56, bool expand = true, EdgeInsets? pad, AlignmentGeometry al = Alignment.center}) {
      final (bg, fg) = segColors(on);
      final b = Btn(onTap: tap, bg: bg, fg: fg, size: size, height: h, padding: pad, alignment: al, child: Text(label));
      return expand ? Expanded(child: b) : b;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel('Time'),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: d.h, minute: d.m),
                    builder: (c, w) => MediaQuery(
                      data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: hour24),
                      child: w!,
                    ),
                  );
                  if (t != null) upd(d.copyWith(h: t.hour, m: t.minute));
                },
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kSurfaceHi,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: kSecondary, width: 2),
                  ),
                  child: Text(hm(d.h, d.m, hour24), style: flex(84, 600, Colors.white, em: -.02, tabular: true)),
                ),
              ),
              const SectionLabel('Label', top: 10),
              const SizedBox(height: 14),
              SizedBox(
                height: 68,
                child: TextField(
                  controller: _label,
                  maxLength: 18,
                  style: flex(28, 500, Colors.white),
                  decoration: _field('Alarm name'),
                  onChanged: (v) => upd(bloc.state.editing!.copyWith(label: v)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Repeat'),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final (i, l) in dayLetter.indexed)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Btn(
                        onTap: () => upd(d.copyWith(days: [...d.days]..[i] = !d.days[i])),
                        bg: segColors(d.days[i]).$1,
                        fg: segColors(d.days[i]).$2,
                        size: 19,
                        width: 46,
                        height: 46,
                        semantics: dayFull[i],
                        child: Text(l),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text('No day selected rings once.', style: flex(17, 400, kMuted)),
              const SectionLabel('Sound', top: 8),
              for (final (i, s) in alarmSounds.indexed)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: seg(s, d.sound == i, () => upd(d.copyWith(sound: i)),
                        size: 22, expand: false, pad: const EdgeInsets.symmetric(horizontal: 24), al: Alignment.centerLeft),
                  ),
                ),
              const SizedBox(height: 12),
              Text('Volume rises gradually over 30 seconds.', style: flex(17, 400, kMuted)),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Snooze'),
              const SizedBox(height: 12),
              Row(children: [
                for (final (i, v) in [5, 10, 15].indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  seg('$v min', d.snooze == v, () => upd(d.copyWith(snooze: v))),
                ],
              ]),
              const SectionLabel('Dismiss with', top: 8),
              const SizedBox(height: 12),
              Row(children: [
                seg('Tap', !d.hold, () => upd(d.copyWith(hold: false))),
                const SizedBox(width: 8),
                seg('Hold 3 s', d.hold, () => upd(d.copyWith(hold: true))),
              ]),
              const SectionLabel('When it rings', top: 8),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  seg('Lights fade on', d.lights, () => upd(d.copyWith(lights: !d.lights)),
                      size: 20, h: 52, expand: false, pad: const EdgeInsets.symmetric(horizontal: 20)),
                  seg('Open blinds', d.blinds, () => upd(d.copyWith(blinds: !d.blinds)),
                      size: 20, h: 52, expand: false, pad: const EdgeInsets.symmetric(horizontal: 20)),
                  seg('AC off', d.ac, () => upd(d.copyWith(ac: !d.ac)),
                      size: 20, h: 52, expand: false, pad: const EdgeInsets.symmetric(horizontal: 20)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Runs through your Google Home or Xiaomi Home scenes.', style: flex(17, 400, kMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
