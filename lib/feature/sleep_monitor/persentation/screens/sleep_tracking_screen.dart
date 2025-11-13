import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../provider/sleep_provider.dart';



class SleepTrackingScreen extends ConsumerStatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  ConsumerState<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
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

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Tracking your sleep...')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            _DecibelMeter(value: decibel),
            SizedBox(height: 16.h),
            Text(_format(_elapsed), style: TextStyle(color: Colors.white, fontSize: 22.sp)),
            SizedBox(height: 8.h),
            Text('Listening for snores', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: ElevatedButton(
                onPressed: _stop,
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 56.h), backgroundColor: const Color(0xFF4A6CF7)),
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
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8.r)),
          child: FractionallySizedBox(
            widthFactor: level,
            alignment: Alignment.centerLeft,
            child: Container(decoration: BoxDecoration(color: const Color(0xFF4A6CF7), borderRadius: BorderRadius.circular(8.r))),
          ),
        ),
        SizedBox(height: 8.h),
        Text('${value.toStringAsFixed(0)} dB', style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
