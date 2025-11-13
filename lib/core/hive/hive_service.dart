import 'package:hive_flutter/hive_flutter.dart';
import '../model/snore_record.dart';

class HiveService {
  static const String _snoreBox = 'snore_records_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SnoreRecordAdapter());
    }
    await Hive.openBox<SnoreRecord>(_snoreBox);
  }

  static Box<SnoreRecord> get _box => Hive.box<SnoreRecord>(_snoreBox);

  static Future<void> addRecord(SnoreRecord record) async {
    await _box.add(record);
  }

  static List<SnoreRecord> getAllRecords() => _box.values.toList();

  static Future<void> clearRecords() async => _box.clear();
}
