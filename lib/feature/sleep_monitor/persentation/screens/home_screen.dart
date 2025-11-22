import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../provider/sleep_provider.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(sleepSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Sleepify")),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Good Evening, Kamran 👋", style: TextStyle(fontSize: 22.sp)),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.go('/tracking'),
              child: const Text("Start Sleep Tracking"),
            ),
            SizedBox(height: 24.h),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Text("Last Night Summary", style: TextStyle(fontSize: 18.sp)),
                    SizedBox(height: 8.h),
                    Text("Total Sleep: ${data.totalSleep.inHours}h ${data.totalSleep.inMinutes % 60}m"),
                    Text("Snore Duration: ${data.snoreDuration.inHours}h ${data.snoreDuration.inMinutes % 60}m"),
                    Text("Avg dB: ${data.avgDb} | Max dB: ${data.maxDb}"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.go('/mesh-wave');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
