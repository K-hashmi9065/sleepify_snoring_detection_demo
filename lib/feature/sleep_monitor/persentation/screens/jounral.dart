import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constant/color_constants.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final int _currentIndex = 2;
  DateTime selectedDate = DateTime.now();

  Color _getIconColor(int index) {
    return _currentIndex == index ? AppColors.primaryBlueColor : Colors.grey;
  }

  List<DateTime> _getWeekDates() {
    final now = DateTime.now();
    final weekDay = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekDay - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  Widget _buildSnoreIndicator({required int intensity}) {
    // Create a more realistic sound wave pattern
    final List<double> waveHeights = intensity == 2
        ? [0.3, 0.5, 0.8, 0.5, 0.3]
        : [0.3, 0.5, 0.7, 1.0, 0.8, 0.6, 0.9, 0.5, 0.3];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        waveHeights.length,
        (index) => Container(
          width: 2.w,
          height: (waveHeights[index] * 16).h,
          margin: EdgeInsets.symmetric(horizontal: 0.5.w),
          decoration: BoxDecoration(
            color: AppColors.muted.withOpacity(0.6),
            borderRadius: BorderRadius.circular(1.r),
          ),
        ),
      ),
    );
  }

  Widget _buildSleepStageCard({
    required double percentage,
    required String duration,
    required String label,
  }) {
    return Row(
      children: [
        // Circular progress indicator
        SizedBox(
          width: 70.w,
          height: 70.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 70.w,
                height: 70.w,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.grey.shade200,
                  ),
                ),
              ),
              // Progress circle
              SizedBox(
                width: 70.w,
                height: 70.w,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlueColor,
                  ),
                ),
              ),
              // Percentage text
              Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        // Duration and Label
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              duration,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 13.sp, color: AppColors.muted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSnoreMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildAudioRecording(String timestamp) {
    return Row(
      children: [
        // Play button
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBlueColor,
          ),
          child: Icon(Icons.play_arrow, color: Colors.white, size: 24.sp),
        ),
        SizedBox(width: 12.w),
        // Timestamp
        Text(
          timestamp,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        SizedBox(width: 12.w),
        // Waveform visualization
        Expanded(
          child: CustomPaint(
            painter: AudioWaveformPainter(),
            size: Size(double.infinity, 30.h),
          ),
        ),
        SizedBox(width: 12.w),
        // Three-dot menu
        Icon(Icons.more_vert, color: AppColors.muted, size: 20.sp),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            "Journal",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25.sp),
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Image.asset(
            'assets/wave/notification-icon.png',
            width: 24.w,
            height: 24.h,
          ),
        ),
        titleSpacing: 18.sp,
        leadingWidth: 55.w,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 25.w),
            child: SizedBox(
              width: 6.w,
              height: 22.h,
              child: Image.asset('assets/wave/menu-icon.png'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekly date selector with progress indicators
              Container(
                padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
                decoration: BoxDecoration(color: AppColors.backgroundColor),
                child: Column(
                  children: [
                    // Week dates row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: _getWeekDates().asMap().entries.map((entry) {
                          final index = entry.key;
                          final date = entry.value;
                          final isSelected =
                              date.day == selectedDate.day &&
                              date.month == selectedDate.month &&
                              date.year == selectedDate.year;

                          // Simulated progress values (you can replace with real data)
                          final progressValues = [
                            0.75,
                            0.65,
                            0.55,
                            0.8,
                            0.7,
                            0.6,
                            0.85,
                          ];
                          final progress = progressValues[index];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: isSelected
                                  ? BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primaryBlueColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                    )
                                  : null,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 8.h,
                              ),
                              child: Column(
                                children: [
                                  // Day name
                                  Text(
                                    _getDayName(date.weekday),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  // Date circle with progress
                                  SizedBox(
                                    width: 50.w,
                                    height: 50.w,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Background circle
                                        SizedBox(
                                          width: 50.w,
                                          height: 50.w,
                                          child: CircularProgressIndicator(
                                            value: 1.0,
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.grey.shade200,
                                                ),
                                          ),
                                        ),
                                        // Progress circle
                                        SizedBox(
                                          width: 50.w,
                                          height: 50.w,
                                          child: CircularProgressIndicator(
                                            value: progress,
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.primaryBlueColor,
                                                ),
                                          ),
                                        ),
                                        // Date text
                                        Text(
                                          '${date.day}',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Selected indicator dot
                                  SizedBox(height: 4.h),
                                  Container(
                                    width: 6.w,
                                    height: 6.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? AppColors.primaryBlueColor
                                          : Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Dropdown arrow
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primaryBlackTextColor,
                      size: 24.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              // Sleep details card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.backgroundColor,
                ),
                child: Row(
                  children: [
                    // Left side - Sleep quality circle
                    SizedBox(
                      width: 120.w,
                      height: 120.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          SizedBox(
                            width: 120.w,
                            height: 120.w,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey.shade200,
                              ),
                            ),
                          ),
                          // Progress circle
                          SizedBox(
                            width: 120.w,
                            height: 120.w,
                            child: CircularProgressIndicator(
                              value: 0.87, // 87% sleep quality
                              strokeWidth: 12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryBlueColor,
                              ),
                            ),
                          ),
                          // Center content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '87',
                                style: TextStyle(
                                  fontSize: 36.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              Text(
                                'Sleep quality',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24.w),
                    // Right side - Sleep details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time in bed
                          Text(
                            '22:30 PM - 06:00 AM',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Time in bed',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          // Time asleep and Awake
                          Row(
                            children: [
                              // Time asleep
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '6h 48m',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Time asleep',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 24.w),
                              // Awake
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '42m',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Awake',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Sleep cycle graph
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.backgroundColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sleep stages labels
                    SizedBox(
                      height: 200.h,
                      child: Row(
                        children: [
                          // Y-axis labels
                          SizedBox(
                            width: 60.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Awake',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                                Text(
                                  'REM',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                                Text(
                                  'Light\nSleep',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.muted,
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  'Deep\nSleep',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.muted,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Graph area
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: CustomPaint(
                                painter: SleepCyclePainter(),
                                child: Container(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // X-axis time labels
                    Padding(
                      padding: EdgeInsets.only(left: 60.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '22:00',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '00:00',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '02:00',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '04:00',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '06:00',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Snore indicators
                    Padding(
                      padding: EdgeInsets.only(left: 60.w),
                      child: Row(
                        children: [
                          Text(
                            'Snore',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSnoreIndicator(intensity: 2),
                                SizedBox(width: 16.w),
                                _buildSnoreIndicator(intensity: 4),
                                SizedBox(width: 16.w),
                                _buildSnoreIndicator(intensity: 2),
                                SizedBox(width: 16.w),
                                _buildSnoreIndicator(intensity: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Sleep Stages breakdown
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.backgroundColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Stages',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // 2x2 Grid of sleep stages
                    Row(
                      children: [
                        // Deep Sleep
                        Expanded(
                          child: _buildSleepStageCard(
                            percentage: 0.43,
                            duration: '3h 13m',
                            label: 'Deep sleep',
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Light Sleep
                        Expanded(
                          child: _buildSleepStageCard(
                            percentage: 0.31,
                            duration: '2h 20m',
                            label: 'Light sleep',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        // REM
                        Expanded(
                          child: _buildSleepStageCard(
                            percentage: 0.17,
                            duration: '1h 15m',
                            label: 'REM',
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Awake
                        Expanded(
                          child: _buildSleepStageCard(
                            percentage: 0.09,
                            duration: '42m',
                            label: 'Awake',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Snore section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.backgroundColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Snore',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Bar chart
                    SizedBox(
                      height: 180.h,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Y-axis labels
                          SizedBox(
                            width: 45.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '80 dB',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                                Text(
                                  '60 dB',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                                Text(
                                  '40 dB',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                                Text(
                                  '20 dB',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                                Text(
                                  '0 dB',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Bar chart area
                          Expanded(
                            child: CustomPaint(
                              painter: SnoreBarChartPainter(),
                              child: Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // X-axis time labels
                    Padding(
                      padding: EdgeInsets.only(left: 45.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '22:00',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '00:00',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '02:00',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '04:00',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '06:00',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Snore metrics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSnoreMetric('2h 25m', 'Snore time'),
                        _buildSnoreMetric('36 dB', 'Avg. snore'),
                        _buildSnoreMetric('64 dB', 'Max. snore'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Sleep Recorder section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.backgroundColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Recorder',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Audio recordings list
                    _buildAudioRecording('00:05'),
                    SizedBox(height: 12.h),
                    _buildAudioRecording('01:06'),
                    SizedBox(height: 12.h),
                    _buildAudioRecording('02:54'),
                    SizedBox(height: 12.h),
                    _buildAudioRecording('03:06'),
                    SizedBox(height: 12.h),
                    _buildAudioRecording('04:28'),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Sleep Note and Wake up Mood combined section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.backgroundColor,
                ),
                child: Column(
                  children: [
                    // Sleep Note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sleep Note',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            color: AppColors.primaryBlueColor,
                          ),
                          child: Text(
                            'Tired',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Gray divider
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                    // Wake up Mood
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Wake up Mood',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Great',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text('😊', style: TextStyle(fontSize: 24.sp)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 89.h,
          child: BottomNavigationBar(
            backgroundColor: AppColors.backgroundColor,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: AppColors.primaryBlueColor,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    context.go('/');
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          _getIconColor(0),
                          BlendMode.srcATop,
                        ),
                        child: Image.asset(
                          'assets/wave/home-icon.png',
                          width: 21.w,
                          height: 22.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    context.go('/mesh-wave');
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          _getIconColor(1),
                          BlendMode.srcATop,
                        ),
                        child: Image.asset(
                          'assets/wave/sounds-icon.png',
                          width: 21.w,
                          height: 22.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
                label: "Sounds",
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          _getIconColor(2),
                          BlendMode.srcATop,
                        ),
                        child: Image.asset(
                          'assets/wave/journal-icon.png',
                          width: 21.w,
                          height: 22.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
                label: "Journal",
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    context.go('/report');
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          _getIconColor(3),
                          BlendMode.srcATop,
                        ),
                        child: Image.asset(
                          'assets/wave/report-icon.png',
                          width: 21.w,
                          height: 22.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
                label: "Report",
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          _getIconColor(4),
                          BlendMode.srcATop,
                        ),
                        child: Image.asset(
                          'assets/wave/profile-icon.png',
                          width: 21.w,
                          height: 22.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for sleep cycle graph
class SleepCyclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define sleep stages as percentages (0 = deep sleep, 1 = awake)
    // Matching the design pattern
    final dataPoints = [
      0.08, // Start awake
      0.08,
      0.12, // Slight dip
      0.25, // Going into REM
      0.45, // Light sleep
      0.75, // Deep sleep
      0.85, // Deepest
      0.65, // Coming back up
      0.35, // REM
      0.25,
      0.40, // Light sleep
      0.55,
      0.80, // Deep sleep again
      0.95, // Deepest point
      0.75, // Coming up
      0.50, // REM
      0.30,
      0.25, // Light REM
      0.15, // Awake period
      0.15,
      0.10, // Back to awake
    ];

    // Calculate spacing between points
    final dx = size.width / (dataPoints.length - 1);

    // Create the main path for the line
    final linePath = Path();
    linePath.moveTo(0, size.height * dataPoints[0]);

    // Create filled path for the gradient area
    final fillPath = Path();
    fillPath.moveTo(0, size.height * dataPoints[0]);

    for (var i = 1; i < dataPoints.length; i++) {
      final x1 = (i - 1) * dx;
      final y1 = size.height * dataPoints[i - 1];
      final x2 = i * dx;
      final y2 = size.height * dataPoints[i];

      // Use quadratic bezier for smooth transitions
      final cp1x = x1 + (x2 - x1) / 2;
      final cp1y = y1;

      linePath.quadraticBezierTo(cp1x, cp1y, x2, y2);
      fillPath.quadraticBezierTo(cp1x, cp1y, x2, y2);
    }

    // Close the fill path to create area under the curve
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Draw the gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryBlueColor.withOpacity(0.15),
          AppColors.primaryBlueColor.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    final linePaint = Paint()
      ..color = AppColors.primaryBlueColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for snore bar chart
class SnoreBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlueColor
      ..style = PaintingStyle.fill;

    // Simulated snore data with thin bars clustered at different times
    // Time labels are at: 22:00(0.2), 00:00(0.4), 02:00(0.6), 04:00(0.8), 06:00(0.95)
    final List<Map<String, double>> snoreBars = [
      // 22:00 - very little/no snoring (start of sleep)
      {'position': 0.18, 'height': 0.10},
      {'position': 0.19, 'height': 0.15},
      {'position': 0.20, 'height': 0.12},
      {'position': 0.21, 'height': 0.08},

      // 00:00 - first snoring cluster
      {'position': 0.37, 'height': 0.20},
      {'position': 0.375, 'height': 0.35},
      {'position': 0.38, 'height': 0.50},
      {'position': 0.385, 'height': 0.65},
      {'position': 0.39, 'height': 0.75},
      {'position': 0.395, 'height': 0.70},
      {'position': 0.40, 'height': 0.78},
      {'position': 0.405, 'height': 0.68},
      {'position': 0.41, 'height': 0.55},
      {'position': 0.415, 'height': 0.40},
      {'position': 0.42, 'height': 0.25},

      // 02:00 - heavy snoring cluster (peak)
      {'position': 0.57, 'height': 0.30},
      {'position': 0.575, 'height': 0.45},
      {'position': 0.58, 'height': 0.60},
      {'position': 0.585, 'height': 0.72},
      {'position': 0.59, 'height': 0.80},
      {'position': 0.595, 'height': 0.75},
      {'position': 0.60, 'height': 0.82},
      {'position': 0.605, 'height': 0.78},
      {'position': 0.61, 'height': 0.70},
      {'position': 0.615, 'height': 0.60},
      {'position': 0.62, 'height': 0.48},
      {'position': 0.625, 'height': 0.35},

      // 04:00 - moderate snoring cluster
      {'position': 0.77, 'height': 0.25},
      {'position': 0.775, 'height': 0.38},
      {'position': 0.78, 'height': 0.52},
      {'position': 0.785, 'height': 0.60},
      {'position': 0.79, 'height': 0.68},
      {'position': 0.795, 'height': 0.62},
      {'position': 0.80, 'height': 0.55},
      {'position': 0.805, 'height': 0.45},
      {'position': 0.81, 'height': 0.32},
      {'position': 0.815, 'height': 0.22},

      // 06:00 - morning snoring cluster
      {'position': 0.92, 'height': 0.35},
      {'position': 0.925, 'height': 0.50},
      {'position': 0.93, 'height': 0.65},
      {'position': 0.935, 'height': 0.75},
      {'position': 0.94, 'height': 0.82},
      {'position': 0.945, 'height': 0.78},
      {'position': 0.95, 'height': 0.85},
      {'position': 0.955, 'height': 0.80},
      {'position': 0.96, 'height': 0.72},
      {'position': 0.965, 'height': 0.60},
      {'position': 0.97, 'height': 0.48},
    ];

    final barWidth = 2.0; // Thin bars like in the design

    for (var bar in snoreBars) {
      final x = bar['position']! * size.width;
      final barHeight = bar['height']! * size.height;
      final y = size.height - barHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        Radius.circular(1),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for audio waveform
class AudioWaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Generate waveform data points
    final int barCount = 60;
    final double barWidth = size.width / barCount;
    final centerY = size.height / 2;

    // Create random-looking waveform pattern
    final List<double> amplitudes = [
      0.3,
      0.5,
      0.7,
      0.4,
      0.6,
      0.8,
      0.5,
      0.3,
      0.4,
      0.6,
      0.7,
      0.9,
      0.6,
      0.4,
      0.5,
      0.7,
      0.8,
      0.6,
      0.4,
      0.3,
      0.5,
      0.7,
      0.6,
      0.4,
      0.5,
      0.8,
      0.9,
      0.7,
      0.5,
      0.4,
      0.6,
      0.7,
      0.5,
      0.3,
      0.4,
      0.6,
      0.8,
      0.7,
      0.5,
      0.4,
      0.5,
      0.7,
      0.9,
      0.8,
      0.6,
      0.4,
      0.5,
      0.7,
      0.6,
      0.4,
      0.3,
      0.5,
      0.6,
      0.4,
      0.5,
      0.7,
      0.6,
      0.5,
      0.4,
      0.3,
    ];

    for (var i = 0; i < barCount; i++) {
      final x = i * barWidth;
      final amplitude = amplitudes[i % amplitudes.length];
      final barHeight = size.height * amplitude * 0.4;

      // Draw vertical line for each bar
      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
