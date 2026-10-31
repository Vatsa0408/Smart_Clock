part of 'clock_bloc.dart';

final class ClockState extends Equatable {
  const ClockState({required this.now, this.hour24 = true});
  final DateTime now;
  final bool hour24;

  /// India has no DST: fixed UTC+5:30.
  DateTime get india => now.toUtc().add(const Duration(hours: 5, minutes: 30));

  /// Offset of India relative to the device zone, e.g. "5 h 30 min ahead".
  String get indiaOffset {
    final local = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final ind = DateTime(india.year, india.month, india.day, india.hour, india.minute);
    final diff = ind.difference(local).inMinutes;
    if (diff == 0) return 'same time';
    final abs = diff.abs();
    final mins = abs % 60 > 0 ? ' ${abs % 60} min' : '';
    final text = '${abs ~/ 60} h$mins ${diff > 0 ? 'ahead' : 'behind'}';
    final dayDiff = DateTime(ind.year, ind.month, ind.day)
        .difference(DateTime(local.year, local.month, local.day))
        .inDays;
    return switch (dayDiff) {
      > 0 => '$text · tomorrow',
      < 0 => '$text · yesterday',
      _ => text,
    };
  }

  ClockState copyWith({DateTime? now, bool? hour24}) =>
      ClockState(now: now ?? this.now, hour24: hour24 ?? this.hour24);

  @override
  List<Object> get props => [now, hour24];
}
