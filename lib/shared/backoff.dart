/// base, 2*base, 4*base ... capped at max.
Duration backoff(
  int attempt, {
  Duration base = const Duration(seconds: 30),
  Duration max = const Duration(minutes: 15),
}) {
  final ms = base.inMilliseconds * (1 << attempt.clamp(0, 20));
  return ms >= max.inMilliseconds ? max : Duration(milliseconds: ms);
}
