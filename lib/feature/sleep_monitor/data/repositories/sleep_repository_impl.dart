import '../../domain/repositories/sleep_repositories.dart';
import '../datasources/microphone_service.dart';

class SleepRepositoryImpl implements SleepRepository {
  final MicrophoneService _mic;

  SleepRepositoryImpl({MicrophoneService? microphone}) : _mic = microphone ?? MicrophoneService();

  @override
  Stream<double> listenDecibel() => _mic.decibelStream;

  @override
  Future<void> startListening() => _mic.start();

  @override
  Future<void> stopListening() => _mic.stop();

  @override
  void dispose() => _mic.dispose();
}
