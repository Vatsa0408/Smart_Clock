part of 'charge_control_bloc.dart';

enum ProtectStatus { unknown, ok, switching, serviceOff, failed }

final class ChargeControlState extends Equatable {
  const ChargeControlState({
    this.protectOn,
    this.serviceEnabled = false,
    this.status = ProtectStatus.unknown,
    this.weakCharger = false,
  });

  /// null until read, and always null on Windows (the section hides).
  final bool? protectOn;
  final bool serviceEnabled;
  final ProtectStatus status;

  /// Plugged in, yet the net current is not positive: the charger cannot keep up with the screen.
  final bool weakCharger;

  ChargeControlState copyWith({
    bool? protectOn,
    bool? serviceEnabled,
    ProtectStatus? status,
    bool? weakCharger,
  }) =>
      ChargeControlState(
        protectOn: protectOn ?? this.protectOn,
        serviceEnabled: serviceEnabled ?? this.serviceEnabled,
        status: status ?? this.status,
        weakCharger: weakCharger ?? this.weakCharger,
      );

  @override
  List<Object?> get props => [protectOn, serviceEnabled, status, weakCharger];
}
