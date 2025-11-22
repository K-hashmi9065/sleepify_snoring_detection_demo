import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../provider/sleep_provider.dart';
import '../provider/session_controller.dart'
    hide SessionController, sessionControllerProvider;
import '../../../../core/model/snore_record.dart';

class SleepTrackingScreen extends ConsumerStatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  ConsumerState<SleepTrackingScreen> createState() =>
      _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends ConsumerState<SleepTrackingScreen> {
  late final SessionController _controller;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(sessionControllerProvider);
    _start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = _elapsed + const Duration(seconds: 1));
    });
  }

  Future<void> _start() async {
    await _controller.start();
  }

  Future<void> _stop() async {
    await _controller.stop();
    _timer?.cancel();
    context.go('/summary');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final decibelAsync = ref.watch(decibelStreamProvider);
    final decibel = decibelAsync.maybeWhen(orElse: () => 0.0, data: (d) => d);
    final recordsAsync = ref.watch(snoreRecordsProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tracking your sleep...'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            // Wave visualization
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      painter: WavePainter(),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 24.h),
            _DecibelMeter(value: decibel),
            SizedBox(height: 16.h),
            Text(
              _format(_elapsed),
              style: TextStyle(color: Colors.white, fontSize: 22.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Listening for snores',
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
            SizedBox(height: 24.h),
            // Database values section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'Database Records',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: recordsAsync.when(
                        data: (records) {
                          if (records.isEmpty) {
                            return Center(
                              child: Text(
                                'No records yet',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14.sp,
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final record = records.reversed.toList()[index];
                              return _RecordCard(record: record);
                            },
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4A6CF7),
                          ),
                        ),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error loading records: $error',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: ElevatedButton(
                onPressed: _stop,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 56.h),
                  backgroundColor: const Color(0xFF4A6CF7),
                ),
                child: Text('Stop', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _DecibelMeter extends StatelessWidget {
  final double value;
  const _DecibelMeter({required this.value});

  @override
  Widget build(BuildContext context) {
    final level = (value / 80).clamp(0.0, 1.0);
    return Column(
      children: [
        Container(
          height: 16.h,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: FractionallySizedBox(
            widthFactor: level,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4A6CF7),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '${value.toStringAsFixed(0)} dB',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

// Wave Painter for the blue wave visualization with overlapping mesh/net structure
// Creates multiple overlapping mesh layers to form a net-like appearance
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fill white background
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    final centerY = size.height / 2;
    final waveAmplitude = size.height * 0.35;
    final waveFrequency = 0.016;
    final random = math.Random(42); // Fixed seed for consistent pattern
    final blueColor = const Color(0xFF4A6CF7);

    // Create multiple overlapping mesh layers (nets)
    final numMeshLayers = 5;
    final gridSpacing = 12.0; // Spacing between grid points
    final lineSpacing = 2.0; // Spacing between parallel lines

    for (int layer = 0; layer < numMeshLayers; layer++) {
      final layerOffset = layer * 8.0; // Phase offset for each layer
      final layerYOffset = (layer - numMeshLayers / 2) * 4.0; // Vertical offset
      final layerOpacity =
          0.25 + (layer / numMeshLayers) * 0.2; // Increasing opacity for depth

      // Generate wave points for this mesh layer
      final List<Offset> wavePoints = [];
      for (double x = 0; x <= size.width; x += gridSpacing) {
        // Complex wave pattern
        final wave1 = math.sin(x * waveFrequency + layerOffset) * waveAmplitude;
        final wave2 =
            math.sin(x * waveFrequency * 2.3 + layerOffset * 1.3) *
            waveAmplitude *
            0.3;
        final wave3 =
            math.sin(x * waveFrequency * 0.7 + layerOffset * 0.8) *
            waveAmplitude *
            0.2;
        final noise = (random.nextDouble() - 0.5) * 5.0;
        final y = centerY + layerYOffset + wave1 + wave2 + wave3 + noise;
        wavePoints.add(Offset(x, y.clamp(0.0, size.height)));
      }

      // Draw horizontal mesh lines (parallel lines following wave)
      final horizontalPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4
        ..color = blueColor.withOpacity(layerOpacity);

      final numHorizontalLines = (waveAmplitude * 2 / lineSpacing).ceil();
      for (int lineIdx = 0; lineIdx < numHorizontalLines; lineIdx++) {
        final lineOffset = (lineIdx - numHorizontalLines / 2) * lineSpacing;
        final List<Offset> linePoints = [];

        for (final wavePoint in wavePoints) {
          final y = (wavePoint.dy + lineOffset).clamp(0.0, size.height);
          linePoints.add(Offset(wavePoint.dx, y));
        }

        // Draw horizontal line
        for (int i = 0; i < linePoints.length - 1; i++) {
          canvas.drawLine(linePoints[i], linePoints[i + 1], horizontalPaint);
        }
      }

      // Draw vertical mesh lines (connecting horizontal lines)
      final verticalPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.35
        ..color = blueColor.withOpacity(layerOpacity * 0.6);

      for (int i = 0; i < wavePoints.length; i++) {
        final wavePoint = wavePoints[i];
        final startY = (wavePoint.dy - waveAmplitude * 0.85).clamp(
          0.0,
          size.height,
        );
        final endY = (wavePoint.dy + waveAmplitude * 0.85).clamp(
          0.0,
          size.height,
        );

        if ((endY - startY) > 3) {
          canvas.drawLine(
            Offset(wavePoint.dx, startY),
            Offset(wavePoint.dx, endY),
            verticalPaint,
          );
        }
      }

      // Draw diagonal mesh connections for net structure
      final diagonalPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.3
        ..color = blueColor.withOpacity(layerOpacity * 0.4);

      for (int i = 0; i < wavePoints.length - 1; i++) {
        final p1 = wavePoints[i];
        final p2 = wavePoints[i + 1];

        // Draw diagonal connections at different heights
        final diagonalOffset = waveAmplitude * 0.3;
        final y1Top = (p1.dy - diagonalOffset).clamp(0.0, size.height);
        final y2Top = (p2.dy - diagonalOffset).clamp(0.0, size.height);
        final y1Bottom = (p1.dy + diagonalOffset).clamp(0.0, size.height);
        final y2Bottom = (p2.dy + diagonalOffset).clamp(0.0, size.height);

        canvas.drawLine(
          Offset(p1.dx, y1Top),
          Offset(p2.dx, y2Top),
          diagonalPaint,
        );
        canvas.drawLine(
          Offset(p1.dx, y1Bottom),
          Offset(p2.dx, y2Bottom),
          diagonalPaint,
        );
      }

      // Draw additional fine mesh lines for density
      final finePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.25
        ..color = blueColor.withOpacity(layerOpacity * 0.3);

      // Connect every other point diagonally for finer mesh
      for (int i = 0; i < wavePoints.length - 2; i += 2) {
        final p1 = wavePoints[i];
        final p2 = wavePoints[i + 2];
        final midY = (p1.dy + p2.dy) / 2;
        final midX = (p1.dx + p2.dx) / 2;

        canvas.drawLine(Offset(p1.dx, p1.dy), Offset(midX, midY), finePaint);
        canvas.drawLine(Offset(midX, midY), Offset(p2.dx, p2.dy), finePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Record Card Widget
class _RecordCard extends StatelessWidget {
  final SnoreRecord record;
  const _RecordCard({required this.record});

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.soundType,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDateTime(record.timestamp),
                style: TextStyle(color: Colors.white70, fontSize: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _InfoItem(
                label: 'Avg dB',
                value: record.avgDb.toStringAsFixed(1),
              ),
              SizedBox(width: 16.w),
              _InfoItem(
                label: 'Max dB',
                value: record.maxDb.toStringAsFixed(1),
              ),
              SizedBox(width: 16.w),
              _InfoItem(
                label: 'Duration',
                value: _formatDuration(record.snoreDuration),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white60, fontSize: 11.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
