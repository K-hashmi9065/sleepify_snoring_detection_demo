import 'dart:async';
import 'dart:math';

/// Simulated microphone service that emits decibel (dB) readings.
/// In production replace this with noise_meter or platform recording.
class MicrophoneService {
  final _controller = StreamController<double>.broadcast();
  Timer? _timer;
  final _random = Random();

  Stream<double> get decibelStream => _controller.stream;

  /// Start simulating decibel readings
  Future<void> start() async {
    // If already started, ignore
    if (_timer != null && _timer!.isActive) return;

    // Start periodic emission (simulate quiet / snore bursts)
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      // simulate base quiet level (5-15) or snore bursts (30-70)
      final burst = _random.nextDouble() > 0.7;
      final value = burst
          ? 30 + _random.nextDouble() * 40 // snore-like
          : 5 + _random.nextDouble() * 10;  // quiet
      _controller.add(value);
    });
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
