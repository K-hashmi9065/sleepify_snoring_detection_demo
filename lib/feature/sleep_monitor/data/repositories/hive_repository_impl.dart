import 'dart:async';
import '../../domain/repositories/sleep_repositories.dart';

class SleepRepositoryImpl implements SleepRepository {
  final _controller = StreamController<double>.broadcast();
  Timer? _timer;
  bool _isListening = false;

  @override
  Stream<double> listenDecibel() => _controller.stream;

  @override
  Future<void> startListening() async {
    if (_isListening) return;
    _isListening = true;
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      final randomDb = 20 + (60 * (0.3 + (0.7 * (DateTime.now().millisecond % 100) / 100)));
      _controller.add(randomDb);
    });
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    _timer?.cancel();
  }

  @override
  void dispose() {
    _controller.close();
  }
}
