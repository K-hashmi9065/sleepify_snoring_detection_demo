import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../provider/session_controller.dart';
import '../../../../core/model/snore_record.dart';

class SleepSummaryScreen extends ConsumerStatefulWidget {
  const SleepSummaryScreen({super.key});

  @override
  ConsumerState<SleepSummaryScreen> createState() => _SleepSummaryScreenState();
}

class _SleepSummaryScreenState extends ConsumerState<SleepSummaryScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh records when screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(snoreRecordsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(snoreRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Recordings')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(snoreRecordsProvider);
          await ref.read(snoreRecordsProvider.future);
        },
        child: recordsAsync.when(
          data: (records) {
            if (records.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic_off,
                          size: 64.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'No recordings yet',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Text(
                            'Start a sleep tracking session to record snore data',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/home'),
                          icon: const Icon(Icons.home),
                          label: const Text('Go to Home'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Sort records by timestamp (newest first)
            final sortedRecords = List<SnoreRecord>.from(records)
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: sortedRecords.length,
                    itemBuilder: (context, index) {
                      final record = sortedRecords[index];
                      return _RecordTile(
                        key: ValueKey(record.timestamp.millisecondsSinceEpoch),
                        record: record,
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 52.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Error loading records',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.invalidate(snoreRecordsProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends StatefulWidget {
  final SnoreRecord record;

  const _RecordTile({super.key, required this.record});

  @override
  State<_RecordTile> createState() => _RecordTileState();
}

// Global audio player manager to ensure only one audio plays at a time
class _AudioPlayerManager {
  static AudioPlayer? _currentPlayer;
  static String? _currentPlayingPath;

  static void setCurrentPlayer(AudioPlayer player, String path) {
    // Stop previous player if different
    if (_currentPlayer != null &&
        _currentPlayer != player &&
        _currentPlayingPath != path) {
      _currentPlayer?.stop();
    }
    _currentPlayer = player;
    _currentPlayingPath = path;
  }

  static void clearCurrentPlayer(AudioPlayer player) {
    if (_currentPlayer == player) {
      _currentPlayer = null;
      _currentPlayingPath = null;
    }
  }
}

class _RecordTileState extends State<_RecordTile> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading =
              state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;

          // Update manager when playing
          if (state.playing && widget.record.audioFilePath != null) {
            _AudioPlayerManager.setCurrentPlayer(
              _audioPlayer,
              widget.record.audioFilePath!,
            );
          } else if (!state.playing) {
            _AudioPlayerManager.clearCurrentPlayer(_audioPlayer);
          }
        });
      }
    });

    // Listen for completion
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && mounted) {
        setState(() {
          _isPlaying = false;
        });
        _AudioPlayerManager.clearCurrentPlayer(_audioPlayer);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _AudioPlayerManager.clearCurrentPlayer(_audioPlayer);
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getSoundTypeColor(String soundType) {
    switch (soundType.toLowerCase()) {
      case 'heavy snore':
        return Colors.red;
      case 'light snore':
        return Colors.orange;
      case 'breathing':
        return Colors.green;
      default:
        return const Color(0xFF4A6CF7);
    }
  }

  Future<void> _playAudio() async {
    if (widget.record.audioFilePath == null ||
        widget.record.audioFilePath!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No audio file available for this recording'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      // On non-web platforms with local file path, ensure the file exists
      if (!kIsWeb) {
        final file = File(widget.record.audioFilePath!);
        if (!await file.exists()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Audio file not found'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      setState(() {
        _isLoading = true;
      });

      // Stop any currently playing audio
      _AudioPlayerManager.setCurrentPlayer(
        _audioPlayer,
        widget.record.audioFilePath!,
      );

      final pathOrUrl = widget.record.audioFilePath!;
      if (kIsWeb ||
          pathOrUrl.startsWith('blob:') ||
          pathOrUrl.startsWith('http')) {
        await _audioPlayer.setUrl(pathOrUrl);
      } else {
        await _audioPlayer.setFilePath(pathOrUrl);
      }
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
        _isPlaying = false;
      });
    }
  }

  Future<void> _pauseAudio() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error pausing audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (recordDate == today) {
      return 'Today';
    } else if (recordDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTime(widget.record.timestamp);
    final dateStr = _formatDate(widget.record.timestamp);
    final durationStr = _formatDuration(widget.record.snoreDuration);
    final soundTypeColor = _getSoundTypeColor(widget.record.soundType);
    final hasAudio =
        widget.record.audioFilePath != null &&
        widget.record.audioFilePath!.isNotEmpty;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: hasAudio ? (_isPlaying ? _pauseAudio : _playAudio) : null,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Play/Pause Button - Always visible
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: hasAudio
                      ? soundTypeColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: _isLoading
                    ? Center(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              hasAudio ? soundTypeColor : Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        hasAudio
                            ? (_isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled)
                            : Icons.play_circle_outline,
                        color: hasAudio ? soundTypeColor : Colors.grey[400],
                        size: 32.sp,
                      ),
              ),
              SizedBox(width: 16.w),
              // Record Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.record.soundType,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: soundTypeColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: soundTypeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            widget.record.maxDb.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: soundTypeColor,
                            ),
                          ),
                        ),
                        Text(
                          ' dB',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$dateStr at $timeStr',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.timer_outlined,
                          size: 14.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          durationStr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.volume_up,
                          size: 12.sp,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Avg: ${widget.record.avgDb.toStringAsFixed(1)} dB',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (!hasAudio) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 12.sp,
                            color: Colors.orange[400],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'No audio',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.orange[400],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
