import 'package:flutter/foundation.dart';

abstract class SleepRepository {
  /// Stream of real-time decibel readings
  Stream<double> listenDecibel();

  /// Start recording/listening
  Future<void> startListening();

  /// Stop recording/listening
  Future<void> stopListening();

  /// Dispose resources
  @mustCallSuper
  void dispose();
}
