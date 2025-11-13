import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/sleep_repository_impl.dart';
import '../../domain/repositories/sleep_repositories.dart';

final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  final repo = SleepRepositoryImpl();
  ref.onDispose(() => repo.dispose());
  return repo;
});

final isTrackingProvider = StateProvider<bool>((ref) => false);

final decibelStreamProvider = StreamProvider<double>((ref) {
  final repo = ref.watch(sleepRepositoryProvider);
  return repo.listenDecibel();
});

class SleepSummary {
  final Duration totalSleep;
  final Duration snoreDuration;
  final double avgDb;
  final double maxDb;

  SleepSummary({
    required this.totalSleep,
    required this.snoreDuration,
    required this.avgDb,
    required this.maxDb,
  });
}

final sleepSummaryProvider = StateProvider<SleepSummary>((ref) {
  return SleepSummary(
    totalSleep: const Duration(hours: 6, minutes: 45),
    snoreDuration: const Duration(hours: 2, minutes: 25),
    avgDb: 36,
    maxDb: 64,
  );
});
