part of 'diagnostics_bloc.dart';

final class DiagnosticsState extends Equatable {
  const DiagnosticsState({this.lines = const []});
  final List<String> lines;

  @override
  List<Object> get props => [lines];
}
