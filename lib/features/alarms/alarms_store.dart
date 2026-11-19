import 'package:equatable/equatable.dart';

/// Alarm sound names. Placeholder: no audio is played yet, the names only label the choice.
const alarmSounds = ['Chime', 'Birdsong', 'YouTube Music playlist'];
const dayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const dayLetter = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const dayFull = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

final class Alarm extends Equatable {
  const Alarm({
    this.id,
    this.h = 7,
    this.m = 0,
    this.label = 'Alarm',
    this.days = const [false, false, false, false, false, false, false],
    this.sound = 0,
    this.snooze = 10,
    this.hold = false,
    this.lights = false,
    this.blinds = false,
    this.ac = false,
    this.on = true,
  });

  /// null = not saved yet.
  final int? id;
  final int h, m, sound, snooze;
  final String label;

  /// Monday first. None selected = rings once.
  final List<bool> days;
  final bool hold, lights, blinds, ac, on;

  bool get noDays => !days.contains(true);
  bool firesOn(int dayIdx) => noDays || days[dayIdx];

  /// Home actions placeholder: no Google/Xiaomi Home integration yet.
  List<String> get actions => [if (lights) 'Lights fade on', if (blinds) 'Blinds open', if (ac) 'AC off'];

  String get summary => [
        alarmSounds[sound],
        'Snooze $snooze min',
        hold ? 'Hold to dismiss' : 'Tap to dismiss',
        ...actions,
      ].join(' · ');

  Alarm copyWith({
    int? id,
    int? h,
    int? m,
    String? label,
    List<bool>? days,
    int? sound,
    int? snooze,
    bool? hold,
    bool? lights,
    bool? blinds,
    bool? ac,
    bool? on,
  }) =>
      Alarm(
        id: id ?? this.id,
        h: h ?? this.h,
        m: m ?? this.m,
        label: label ?? this.label,
        days: days ?? this.days,
        sound: sound ?? this.sound,
        snooze: snooze ?? this.snooze,
        hold: hold ?? this.hold,
        lights: lights ?? this.lights,
        blinds: blinds ?? this.blinds,
        ac: ac ?? this.ac,
        on: on ?? this.on,
      );

  Map<String, Object?> toJson() => {
        'id': id, 'h': h, 'm': m, 'l': label, 'd': days, 's': sound, 'sn': snooze,
        'ho': hold, 'li': lights, 'bl': blinds, 'ac': ac, 'on': on,
      };

  factory Alarm.fromJson(Map<String, dynamic> j) => Alarm(
        id: j['id'] as int?,
        h: j['h'] as int? ?? 7,
        m: j['m'] as int? ?? 0,
        label: j['l'] as String? ?? 'Alarm',
        days: (j['d'] as List?)?.cast<bool>() ?? const [false, false, false, false, false, false, false],
        sound: ((j['s'] as int?) ?? 0).clamp(0, alarmSounds.length - 1),
        snooze: j['sn'] as int? ?? 10,
        hold: j['ho'] as bool? ?? false,
        lights: j['li'] as bool? ?? false,
        blinds: j['bl'] as bool? ?? false,
        ac: j['ac'] as bool? ?? false,
        on: j['on'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [id, h, m, label, days, sound, snooze, hold, lights, blinds, ac, on];
}

/// Soonest enabled alarm after [now]: [d] days ahead (0 = today) on weekday [idx] (Mon = 0).
({int d, int idx, Alarm alarm})? nextAlarm(List<Alarm> alarms, DateTime now) {
  final di = now.weekday - 1, nowMin = now.hour * 60 + now.minute;
  ({int d, int idx, Alarm alarm})? best;
  var bestDelta = 1 << 30;
  for (final a in alarms.where((a) => a.on)) {
    final am = a.h * 60 + a.m;
    for (var d = 0; d < 8; d++) {
      final idx = (di + d) % 7;
      if (a.firesOn(idx) && (d > 0 || am > nowMin)) {
        final delta = d * 1440 + am - nowMin;
        if (delta < bestDelta) {
          bestDelta = delta;
          best = (d: d, idx: idx, alarm: a);
        }
        break;
      }
    }
  }
  return best;
}

/// "Today 06:30" / "Tomorrow 06:30" / "Mon 06:30" / "No alarm".
String nextAlarmText(List<Alarm> alarms, DateTime now, String Function(int h, int m) fmt) =>
    switch (nextAlarm(alarms, now)) {
      null => 'No alarm',
      (:final d, :final idx, :final alarm) =>
        '${d == 0 ? 'Today' : d == 1 ? 'Tomorrow' : dayShort[idx]} ${fmt(alarm.h, alarm.m)}',
    };

/// Seed list for a fresh install (from the design).
const defaultAlarms = [
  Alarm(id: 1, h: 6, m: 30, label: 'Work', days: [true, true, true, true, true, false, false], hold: true, lights: true),
  Alarm(id: 2, h: 8, m: 30, label: 'Weekend', days: [false, false, false, false, false, true, true], sound: 2, blinds: true),
  Alarm(id: 3, h: 18, m: 45, label: 'Gym', days: [false, true, false, true, false, false, false], sound: 1, snooze: 5, on: false),
];
