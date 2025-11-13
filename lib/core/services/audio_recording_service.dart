import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as path;

class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;

  /// Start recording audio
  Future<String?> startRecording() async {
    if (_isRecording) {
      return _currentRecordingPath;
    }

    try {
      // Request microphone permission
      if (await _recorder.hasPermission()) {
        if (kIsWeb) {
          // On web, do not provide a filesystem path. The plugin will manage a Blob URL.
          await _recorder.start(
            const RecordConfig(
              // Web commonly uses webm/opus in browsers
              encoder: AudioEncoder.opus,
              //  encoder: AudioEncoder.opus,
              bitRate: 128000,
              sampleRate: 44100,
            ),
            path: '',
          );
          _currentRecordingPath = null;
        } else {
          // Get directory for storing recordings (mobile/desktop)
          final directory = await getApplicationDocumentsDirectory();
          final recordingsDir = path.join(directory.path, 'recordings');

          // Create directory if it doesn't exist
          final dir = Directory(recordingsDir);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }

          // Generate unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'snore_$timestamp.m4a';
          _currentRecordingPath = path.join(recordingsDir, fileName);

          // Start recording
          await _recorder.start(
            const RecordConfig(
              encoder: AudioEncoder.aacLc,
              bitRate: 128000,
              sampleRate: 44100,
            ),
            path: _currentRecordingPath!,
          );
        }

        _isRecording = true;
        return _currentRecordingPath;
      } else {
        throw Exception('Microphone permission not granted');
      }
    } catch (e) {
      print('Error starting recording: $e');
      return null;
    }
  }

  /// Stop recording audio
  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return _currentRecordingPath;
    }

    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _currentRecordingPath = path;
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return _currentRecordingPath;
    }
  }

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Get current recording path
  String? get currentRecordingPath => _currentRecordingPath;

  /// Dispose resources
  Future<void> dispose() async {
    if (_isRecording) {
      await stopRecording();
    }
    await _recorder.dispose();
  }
}
