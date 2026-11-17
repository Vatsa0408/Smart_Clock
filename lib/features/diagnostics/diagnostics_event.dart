part of 'diagnostics_bloc.dart';

sealed class DiagnosticsEvent {
  const DiagnosticsEvent();
}

final class DiagnosticsOpened extends DiagnosticsEvent {
  const DiagnosticsOpened();
}

final class DiagnosticsCleared extends DiagnosticsEvent {
  const DiagnosticsCleared();
}
