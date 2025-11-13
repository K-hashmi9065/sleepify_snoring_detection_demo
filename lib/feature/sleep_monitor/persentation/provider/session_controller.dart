import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/hive/hive_service.dart';
import '../../../../core/model/snore_record.dart';
import '../../../../core/services/audio_recording_service.dart';
import '../../domain/repositories/sleep_repositories.dart';
import 'sleep_provider.dart';

final sessionControllerProvider = Provider<SessionController>((ref) {
  final repo = ref.watch(sleepRepositoryProvider);
  final controller = SessionController(repo, ref);
  ref.onDispose(() => controller.dispose());
  return controller;
});

final snoreRecordsProvider = FutureProvider<List<SnoreRecord>>((ref) async {
  return HiveService.getAllRecords();
});

class SessionController {
  final SleepRepository _repo;
  final Ref _ref;
  final AudioRecordingService _audioRecorder = AudioRecordingService();
  StreamSubscription<double>? _sub;
  List<double> _sessionValues = [];

  SessionController(this._repo, this._ref);

  Future<void> start() async {
    await _repo.startListening();

    // Start audio recording
    await _audioRecorder.startRecording();

    _ref.read(isTrackingProvider.notifier).state = true;

    _sub = _repo.listenDecibel().listen((db) {
      _sessionValues.add(db);
    });
  }

  Future<void> stop() async {
    await _repo.stopListening();

    // Stop audio recording
    final audioFilePath = await _audioRecorder.stopRecording();

    await _sub?.cancel();
    _ref.read(isTrackingProvider.notifier).state = false;

    if (_sessionValues.isNotEmpty) {
      final avg =
          _sessionValues.reduce((a, b) => a + b) / _sessionValues.length;
      final max = _sessionValues.reduce((a, b) => a > b ? a : b);
      final snoreDuration = Duration(seconds: _sessionValues.length ~/ 2);

      final type = max > 50
          ? "Heavy Snore"
          : avg > 35
          ? "Light Snore"
          : "Breathing";

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
        totalSleep: const Duration(hours: 6),
        snoreDuration: snoreDuration,
        avgDb: avg,
        maxDb: max,
      );
    }

    _sessionValues = [];
  }

  List<SnoreRecord> getStoredRecords() => HiveService.getAllRecords();

  void dispose() {
    _sub?.cancel();
    _audioRecorder.dispose();
  }
}
