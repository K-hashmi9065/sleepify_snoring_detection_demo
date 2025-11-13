import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/sleep_repository_impl.dart';
import '../../domain/repositories/sleep_repositories.dart';
import '../../../../core/hive/hive_service.dart';
import '../../../../core/model/snore_record.dart';
import '../../../../core/services/audio_recording_service.dart';

/// Provides the repository (data layer)
final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  final repo = SleepRepositoryImpl();
  ref.onDispose(repo.dispose);
  return repo;
});

/// Whether user is currently tracking sleep
final isTrackingProvider = StateProvider<bool>((ref) => false);

/// Stream of real-time decibel readings
final decibelStreamProvider = StreamProvider<double>((ref) {
  final repo = ref.watch(sleepRepositoryProvider);
  return repo.listenDecibel();
});

/// Sleep summary model
class SleepSummary {
  final Duration totalSleep;
  final Duration snoreDuration;
  final double avgDb;
  final double maxDb;

  const SleepSummary({
    required this.totalSleep,
    required this.snoreDuration,
    required this.avgDb,
    required this.maxDb,
  });
}

/// Holds the latest sleep summary (default mock data)
final sleepSummaryProvider = StateProvider<SleepSummary>((ref) {
  return const SleepSummary(
    totalSleep: Duration(hours: 6, minutes: 45),
    snoreDuration: Duration(hours: 2, minutes: 25),
    avgDb: 36,
    maxDb: 64,
  );
});

/// Stores decibel values for the current session
final _sessionDecibelsProvider = StateProvider<List<double>>((ref) => []);

/// Controls starting/stopping a sleep tracking session
final sessionControllerProvider = Provider<SessionController>((ref) {
  final repo = ref.watch(sleepRepositoryProvider);
  final session = SessionController(repo, ref);
  ref.onDispose(session.dispose);
  return session;
});

class SessionController {
  final SleepRepository _repo;
  final Ref _ref;
  final AudioRecordingService _audioRecorder = AudioRecordingService();
  StreamSubscription<double>? _subscription;
  Timer? _timer;
  int _seconds = 0;

  SessionController(this._repo, this._ref);

  /// Starts listening and collecting decibel values
  Future<void> start() async {
    await _repo.startListening();

    // Start audio recording
    await _audioRecorder.startRecording();

    _ref.read(isTrackingProvider.notifier).state = true;
    _ref.read(_sessionDecibelsProvider.notifier).state = [];
    _seconds = 0;

    // Stream listener for decibel updates
    _subscription = _repo.listenDecibel().listen((db) {
      final current = List<double>.from(_ref.read(_sessionDecibelsProvider));
      current.add(db);
      _ref.read(_sessionDecibelsProvider.notifier).state = current;
    });

    // Timer to simulate session duration
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _seconds++);
  }

  /// Stops listening and updates the summary
  Future<void> stop() async {
    await _repo.stopListening();

    // Stop audio recording
    final audioFilePath = await _audioRecorder.stopRecording();

    await _subscription?.cancel();
    _subscription = null;
    _timer?.cancel();

    _ref.read(isTrackingProvider.notifier).state = false;

    final sessionData = _ref.read(_sessionDecibelsProvider);
    if (sessionData.isNotEmpty) {
      final avg = sessionData.reduce((a, b) => a + b) / sessionData.length;
      final max = sessionData.reduce((a, b) => a > b ? a : b);

      // Consider >30 dB as snore sound
      final snoreSamples = sessionData.where((x) => x > 30).length;
      final snoreSeconds = (snoreSamples * 1).toInt();

      final totalSleep = Duration(seconds: _seconds);
      final snoreDuration = Duration(seconds: snoreSeconds);

      // Determine sound type based on decibel levels
      final type = max > 50
          ? "Heavy Snore"
          : avg > 35
          ? "Light Snore"
          : "Breathing";

      // Save record to Hive with audio file path
      final record = SnoreRecord.fromDuration(
        timestamp: DateTime.now(),
        soundType: type,
        avgDb: avg,
        maxDb: max,
        snoreDuration: snoreDuration,
        audioFilePath: audioFilePath,
      );

      await HiveService.addRecord(record);

      _ref.read(sleepSummaryProvider.notifier).state = SleepSummary(
        totalSleep: totalSleep,
        snoreDuration: snoreDuration,
        avgDb: avg,
        maxDb: max,
      );
    }

    // Clear session data
    _ref.read(_sessionDecibelsProvider.notifier).state = [];
  }

  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
    _audioRecorder.dispose();
  }
}
