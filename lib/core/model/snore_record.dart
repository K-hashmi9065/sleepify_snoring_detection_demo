import 'package:hive/hive.dart';

part 'snore_record.g.dart'; // Run:  build

@HiveType(typeId: 0)
class SnoreRecord extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final String soundType; // "Light Snore", "Heavy Snore", "Breathing"

  @HiveField(2)
  final double avgDb;

  @HiveField(3)
  final double maxDb;

  @HiveField(4)
  final int snoreDurationMs; // Duration stored as milliseconds

  @HiveField(5)
  final String? audioFilePath; // Path to recorded audio file

  SnoreRecord({
    required this.timestamp,
    required this.soundType,
    required this.avgDb,
    required this.maxDb,
    required this.snoreDurationMs,
    this.audioFilePath,
  });

  // Helper getter to convert milliseconds back to Duration
  Duration get snoreDuration => Duration(milliseconds: snoreDurationMs);

  // Factory constructor to create from Duration
  factory SnoreRecord.fromDuration({
    required DateTime timestamp,
    required String soundType,
    required double avgDb,
    required double maxDb,
    required Duration snoreDuration,
    String? audioFilePath,
  }) {
    return SnoreRecord(
      timestamp: timestamp,
      soundType: soundType,
      avgDb: avgDb,
      maxDb: maxDb,
      snoreDurationMs: snoreDuration.inMilliseconds,
      audioFilePath: audioFilePath,
    );
  }
}
