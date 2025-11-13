class SleepData {
  final Duration totalSleep;
  final Duration snoreDuration;
  final double avgDb;
  final double maxDb;

  const SleepData({
    required this.totalSleep,
    required this.snoreDuration,
    required this.avgDb,
    required this.maxDb,
  });
}
