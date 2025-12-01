import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constant/color_constants.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final int _currentIndex = 3;
  String _selectedPeriod = 'Weekly'; // Weekly, Monthly, Yearly
  int _periodOffset = 0; // To track navigation through periods
  int _selectedTimeTab = 0; // 0=Went to bed, 1=Fell Asleep, 2=Woke up

  Color _getIconColor(int index) {
    return _currentIndex == index ? AppColors.primaryBlueColor : Colors.grey;
  }

  String _getDateRangeText() {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    if (_selectedPeriod == 'Weekly') {
      // Calculate the start of the week (Sunday)
      final weekStart = now.subtract(Duration(days: now.weekday % 7));
      start = weekStart.add(Duration(days: _periodOffset * 7));
      end = start.add(const Duration(days: 6));

      // Format: Dec 16 - Dec 22, 2025
      final startMonth = DateFormat.MMM().format(start);
      final endMonth = DateFormat.MMM().format(end);
      final startDay = start.day;
      final endDay = end.day;
      final year = end.year;

      if (start.month == end.month) {
        return '$startMonth $startDay - $endDay, $year';
      } else {
        return '$startMonth $startDay - $endMonth $endDay, $year';
      }
    } else if (_selectedPeriod == 'Monthly') {
      // Calculate the month based on offset
      start = DateTime(now.year, now.month + _periodOffset, 1);
      end = DateTime(start.year, start.month + 1, 0);

      // Format: December 2025
      return DateFormat.yMMMM().format(start);
    } else {
      // Yearly
      final year = now.year + _periodOffset;
      return '$year';
    }
  }

  void _navigatePeriod(int direction) {
    setState(() {
      _periodOffset += direction;
    });
  }

  Widget _buildPeriodTab(String label) {
    final isSelected = _selectedPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = label;
            _periodOffset = 0; // Reset offset when changing period type
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 15.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlueColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppColors.primaryBlackTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSleepQualityChart() {
    // Sample data for 7 days
    final List<Map<String, dynamic>> weekData = [
      {'day': 16, 'quality': 90, 'isToday': false},
      {'day': 17, 'quality': 72, 'isToday': true},
      {'day': 18, 'quality': 85, 'isToday': false},
      {'day': 19, 'quality': 95, 'isToday': false},
      {'day': 20, 'quality': 78, 'isToday': false},
      {'day': 21, 'quality': 88, 'isToday': false},
      {'day': 22, 'quality': 92, 'isToday': false},
    ];

    return SizedBox(
      height: 250.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Y-axis labels
          SizedBox(
            width: 35.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '100',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primaryGrayTextColor,
                  ),
                ),
                Text(
                  '80',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primaryGrayTextColor,
                  ),
                ),
                Text(
                  '60',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primaryGrayTextColor,
                  ),
                ),
                Text(
                  '40',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primaryGrayTextColor,
                  ),
                ),
                Text(
                  '20',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primaryGrayTextColor,
                  ),
                ),
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primaryGrayTextColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Chart bars
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: weekData.map((data) {
                      return _buildBar(
                        day: data['day'],
                        quality: data['quality'],
                        isToday: data['isToday'],
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 8.h),
                // X-axis labels (days)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: weekData.map((data) {
                    return SizedBox(
                      width: 35.w,
                      child: Center(
                        child: Text(
                          '${data['day']}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primaryGrayTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required int day,
    required int quality,
    required bool isToday,
  }) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 25.w,
            height: (quality / 100) * 200.h,
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.primaryBlueColor
                  : AppColors.primaryBlueColor.withOpacity(0.3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
          ),
          // Score badge for today
          if (isToday)
            Positioned(
              top: -90.h,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlueColor,
                        width: 6,
                      ),
                    ),
                    child: Text(
                      '$quality',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Triangle pointer
                  CustomPaint(
                    size: Size(20.w, 10.h),
                    painter: TrianglePainter(color: AppColors.primaryBlueColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeTab(String label, int index) {
    final isSelected = _selectedTimeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlueColor : Colors.transparent,
          borderRadius: BorderRadius.circular(45.r),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.primaryBlackTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBedtimeChart() {
    // Sample data for bedtime over 7 days (in hours from midnight, e.g., 23.5 = 23:30)
    final List<Map<String, dynamic>> bedtimeData = [
      {'day': 16, 'time': 23.5, 'isToday': false}, // 23:30
      {'day': 17, 'time': 23.0, 'isToday': false}, // 23:00
      {'day': 18, 'time': 23.8, 'isToday': false}, // 23:48
      {'day': 19, 'time': 23.25, 'isToday': true}, // 23:15
      {'day': 20, 'time': 23.3, 'isToday': false}, // 23:18
      {'day': 21, 'time': 22.5, 'isToday': false}, // 22:30
      {'day': 22, 'time': 23.5, 'isToday': false}, // 23:30
    ];

    return SizedBox(
      height: 300.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Y-axis time labels
          SizedBox(
            width: 45.w,
            height: 300.h,
            child: Stack(
              children: [
                // Positioned to match the chart area (top 50 to bottom 20)
                Positioned(
                  top: 50.0, // Match painter topPadding
                  bottom: 20.0, // Match painter bottomPadding
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildYAxisLabel('00:00'),
                      _buildYAxisLabel('23:30'),
                      _buildYAxisLabel('23:00'),
                      _buildYAxisLabel('22:30'),
                      _buildYAxisLabel('22:00'),
                      _buildYAxisLabel('21:30'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Line chart and X-axis labels
          Expanded(
            child: Stack(
              children: [
                // Chart
                Positioned.fill(
                  child: CustomPaint(
                    painter: BedtimeLinePainter(data: bedtimeData),
                  ),
                ),
                // X-axis day labels
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: bedtimeData.map((data) {
                      return SizedBox(
                        width: 30.w, // Fixed width for alignment
                        child: Center(
                          child: Text(
                            '${data['day']}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.primaryGrayTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabel(String text) {
    return Transform.translate(
      offset: const Offset(0, 0), // Adjust if needed
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: AppColors.primaryGrayTextColor,
          height: 1.0, // Reduce line height for better vertical centering
        ),
      ),
    );
  }

  Widget _buildSleepStagesChart() {
    // Sample data for sleep stages (0-5 hours)
    final List<Map<String, dynamic>> stagesData = [
      {'day': 16, 'time': 3.8, 'isToday': false},
      {'day': 17, 'time': 3.35, 'isToday': true}, // 3h 21m
      {'day': 18, 'time': 4.0, 'isToday': false},
      {'day': 19, 'time': 2.9, 'isToday': false},
      {'day': 20, 'time': 4.8, 'isToday': false},
      {'day': 21, 'time': 4.2, 'isToday': false},
      {'day': 22, 'time': 3.2, 'isToday': false},
    ];

    return SizedBox(
      height: 300.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Y-axis labels
          SizedBox(
            width: 45.w,
            height: 300.h,
            child: Stack(
              children: [
                Positioned(
                  top: 50.0,
                  bottom: 20.0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildYAxisLabel('5h'),
                      _buildYAxisLabel('4h'),
                      _buildYAxisLabel('3h'),
                      _buildYAxisLabel('2h'),
                      _buildYAxisLabel('1h'),
                      _buildYAxisLabel('0h'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Line chart
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: SleepStagesPainter(data: stagesData),
                  ),
                ),
                // X-axis labels
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: stagesData.map((data) {
                      return SizedBox(
                        width: 30.w,
                        child: Center(
                          child: Text(
                            '${data['day']}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.primaryGrayTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnoreTimeChart() {
    // Sample data for snore time (0-2.5 hours)
    final List<Map<String, dynamic>> snoreData = [
      {'day': 16, 'hours': 2.2, 'isToday': false},
      {'day': 17, 'hours': 1.4, 'isToday': false},
      {'day': 18, 'hours': 1.63, 'isToday': true}, // 1h 38m
      {'day': 19, 'hours': 1.8, 'isToday': false},
      {'day': 20, 'hours': 2.4, 'isToday': false},
      {'day': 21, 'hours': 1.5, 'isToday': false},
      {'day': 22, 'hours': 2.5, 'isToday': false},
    ];

    return SizedBox(
      height: 300.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Y-axis labels
          SizedBox(
            width: 45.w,
            height: 300.h,
            child: Stack(
              children: [
                Positioned(
                  top: 50.0,
                  bottom: 20.0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildYAxisLabel('2.5h'),
                      _buildYAxisLabel('2h'),
                      _buildYAxisLabel('1.5h'),
                      _buildYAxisLabel('1h'),
                      _buildYAxisLabel('0.5h'),
                      _buildYAxisLabel('0h'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Bar chart
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: SnoreTimePainter(data: snoreData),
                  ),
                ),
                // X-axis labels
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: snoreData.map((data) {
                      return SizedBox(
                        width: 30.w,
                        child: Center(
                          child: Text(
                            '${data['day']}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.primaryGrayTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepDurationChart() {
    // Sample data for sleep duration
    final List<Map<String, dynamic>> durationData = [
      {'day': 16, 'hours': 8.5, 'isToday': false},
      {'day': 17, 'hours': 6.2, 'isToday': false},
      {'day': 18, 'hours': 9.1, 'isToday': false},
      {'day': 19, 'hours': 7.5, 'isToday': false},
      {'day': 20, 'hours': 7.1, 'isToday': true}, // 7h 5m
      {'day': 21, 'hours': 8.0, 'isToday': false},
      {'day': 22, 'hours': 6.5, 'isToday': false},
    ];

    return SizedBox(
      height: 300.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Y-axis labels
          SizedBox(
            width: 45.w,
            height: 300.h,
            child: Stack(
              children: [
                Positioned(
                  top: 50.0,
                  bottom: 20.0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildYAxisLabel('10h'),
                      _buildYAxisLabel('8h'),
                      _buildYAxisLabel('6h'),
                      _buildYAxisLabel('4h'),
                      _buildYAxisLabel('2h'),
                      _buildYAxisLabel('0h'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Bar chart
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: SleepDurationPainter(data: durationData),
                  ),
                ),
                // X-axis labels
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: durationData.map((data) {
                      return SizedBox(
                        width: 30.w,
                        child: Center(
                          child: Text(
                            '${data['day']}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.primaryGrayTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWakeUpMoodSection() {
    final List<Map<String, dynamic>> moodData = [
      {'day': 16, 'mood': 'Good', 'emoji': '😊', 'isToday': false},
      {'day': 17, 'mood': 'Not Good', 'emoji': '😢', 'isToday': false},
      {'day': 18, 'mood': 'Bad', 'emoji': '😵‍💫', 'isToday': false},
      {'day': 19, 'mood': 'Great', 'emoji': '😎', 'isToday': false},
      {'day': 20, 'mood': 'Good', 'emoji': '😊', 'isToday': false},
      {'day': 21, 'mood': 'Okay', 'emoji': '😐', 'isToday': false},
      {'day': 22, 'mood': 'Great', 'emoji': '😎', 'isToday': true},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moodData.map((data) {
        final isToday = data['isToday'] as bool;
        return Column(
          children: [
            Text(data['emoji'], style: TextStyle(fontSize: 24.sp)),
            SizedBox(height: 8.h),
            Text(
              data['mood'],
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.primaryGrayTextColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${data['day']}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? const Color(0xFF6366F1)
                    : AppColors.primaryBlackTextColor,
              ),
            ),
          ],
        );
      }).toList(),
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
            "Report",
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
              // Period selector and date range section
              Container(
                decoration: BoxDecoration(color: AppColors.backgroundColor),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      // Weekly/Monthly/Yearly tabs
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          children: [
                            _buildPeriodTab('Weekly'),
                            SizedBox(width: 6.w),
                            _buildPeriodTab('Monthly'),
                            SizedBox(width: 6.w),
                            _buildPeriodTab('Yearly'),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Date range selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left arrow
                          GestureDetector(
                            onTap: () => _navigatePeriod(-1),
                            child: Icon(
                              Icons.chevron_left,
                              size: 28.sp,
                              color: AppColors.primaryBlackTextColor,
                            ),
                          ),
                          SizedBox(width: 20.w),
                          // Date range text
                          Text(
                            _getDateRangeText(),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlackTextColor,
                            ),
                          ),
                          SizedBox(width: 20.w),
                          // Right arrow
                          GestureDetector(
                            onTap: () => _navigatePeriod(1),
                            child: Icon(
                              Icons.chevron_right,
                              size: 28.sp,
                              color: AppColors.primaryBlackTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Sleep Quality Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Quality',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlackTextColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Divider line
                      Container(height: 1.h, color: const Color(0xFFE5E5E5)),
                      SizedBox(height: 24.h),
                      _buildSleepQualityChart(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Bedtime & Wake up time Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bedtime & Wake up time',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlackTextColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Divider line
                      Container(height: 1.h, color: const Color(0xFFE5E5E5)),
                      SizedBox(height: 15.h),
                      // Time type tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTimeTab('Went to bed', 0),
                            SizedBox(width: 8.w),
                            _buildTimeTab('Fell Asleep', 1),
                            SizedBox(width: 8.w),
                            _buildTimeTab('Woke up', 2),
                          ],
                        ),
                      ),
                      // SizedBox(height: 15.h),
                      _buildBedtimeChart(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),
              // Sleep Duration Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Duration',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlackTextColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Divider line
                      Container(height: 1.h, color: const Color(0xFFE5E5E5)),
                      SizedBox(height: 24.h),
                      _buildSleepDurationChart(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Sleep Stages Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Stages',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlackTextColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Divider line
                      Container(height: 1.h, color: const Color(0xFFE5E5E5)),
                      SizedBox(height: 15.h),
                      // Stages tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTimeTab('Deep', 0), // Reusing style for now
                            SizedBox(width: 8.w),
                            _buildTimeTab('Light', 1),
                            SizedBox(width: 8.w),
                            _buildTimeTab('REM', 2),
                            SizedBox(width: 8.w),
                            _buildTimeTab('Awake', 3),
                          ],
                        ),
                      ),
                      _buildSleepStagesChart(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Snore Time Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Snore Time',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlackTextColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Divider line
                      Container(height: 1.h, color: const Color(0xFFE5E5E5)),
                      SizedBox(height: 24.h),
                      _buildSnoreTimeChart(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Wake up Mood Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wake up Mood',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlackTextColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Divider line
                      Container(height: 1.h, color: const Color(0xFFE5E5E5)),
                      SizedBox(height: 20.h),
                      _buildWakeUpMoodSection(),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Rest of the report content will go here
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
                  onTap: () {
                    context.go('/journal');
                  },
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
                  onTap: () {},
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
                label: "Account",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for triangle pointer
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height); // Bottom center point
    path.lineTo(0, 0); // Top left
    path.lineTo(size.width, 0); // Top right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for bedtime line chart
class BedtimeLinePainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  BedtimeLinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color =
          const Color(0xFF6366F1) // Purple/blue color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    final circleStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Calculate positions
    final points = <Offset>[];
    const topPadding = 50.0; // Space for badge at top
    const bottomPadding = 20.0;
    final chartHeight = size.height - topPadding - bottomPadding;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      // Map time (21.5-24 hours) to chart height
      // 24 = top, 21.5 = bottom
      final time = data[i]['time'] as double;
      final y = topPadding + ((24 - time) / 2.5) * chartHeight;
      points.add(Offset(x, y));
    }

    // Draw filled area under the line
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height - bottomPadding);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height - bottomPadding);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw circles at each point
    for (int i = 0; i < points.length; i++) {
      // Draw outer circle (border)
      canvas.drawCircle(points[i], 8, circleStrokePaint);

      // Draw inner circle
      canvas.drawCircle(points[i], 5, circlePaint);

      // Draw time badge for today's point
      if (data[i]['isToday'] == true) {
        _drawTimeBadge(canvas, points[i], data[i]['time'] as double);
      }
    }
  }

  void _drawTimeBadge(Canvas canvas, Offset position, double time) {
    // Convert time to HH:MM format
    final hours = time.floor();
    final minutes = ((time - hours) * 60).round();
    final timeStr = '$hours:${minutes.toString().padLeft(2, '0')}';

    // Badge dimensions
    const badgeRadius = 22.0;
    const pointerHeight = 8.0;
    const pointerWidth = 12.0;

    final badgeCenter = Offset(position.dx, position.dy - 40);

    // Draw badge with pointer
    final badgePath = Path();

    // Circle
    badgePath.addOval(
      Rect.fromCircle(center: badgeCenter, radius: badgeRadius),
    );

    // Pointer
    final pointerPath = Path();
    pointerPath.moveTo(
      badgeCenter.dx - pointerWidth / 2,
      badgeCenter.dy + badgeRadius - 2,
    ); // Overlap slightly
    pointerPath.lineTo(
      badgeCenter.dx,
      badgeCenter.dy + badgeRadius + pointerHeight,
    );
    pointerPath.lineTo(
      badgeCenter.dx + pointerWidth / 2,
      badgeCenter.dy + badgeRadius - 2,
    );
    pointerPath.close();

    badgePath.addPath(pointerPath, Offset.zero);

    // Draw badge shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(badgePath.shift(const Offset(0, 2)), shadowPaint);

    // Draw badge background (white)
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(badgePath, bgPaint);

    // Draw badge border (blue)
    final borderPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4; // Thicker border
    canvas.drawPath(badgePath, borderPaint);

    // Draw time text
    final textPainter = TextPainter(
      text: TextSpan(
        text: timeStr,
        style: const TextStyle(
          color: AppColors.primaryBlackTextColor,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        badgeCenter.dx - textPainter.width / 2,
        badgeCenter.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for sleep duration bar chart
class SleepDurationPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  SleepDurationPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    const topPadding = 50.0;
    const bottomPadding = 20.0;
    final chartHeight = size.height - topPadding - bottomPadding;
    final barWidth = size.width / (data.length * 2 - 1);

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final hours = item['hours'] as double;
      final isToday = item['isToday'] as bool;

      // Calculate bar height (max 10h)
      final barHeight = (hours / 10.0) * chartHeight;

      // Calculate position
      final x =
          i * (size.width / data.length) +
          (size.width / data.length - barWidth) / 2;
      final y = topPadding + (chartHeight - barHeight);

      // Draw bar
      paint.color = isToday
          ? const Color(0xFF6366F1)
          : const Color(0xFF6366F1).withOpacity(0.4);

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
      );
      canvas.drawRRect(rrect, paint);

      // Draw badge for today
      if (isToday) {
        _drawBadge(canvas, Offset(x + barWidth / 2, y), hours);
      }
    }
  }

  void _drawBadge(Canvas canvas, Offset position, double hours) {
    // Convert hours to "7h 5m" format
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    final timeStr = '${h}h ${m}m';

    // Badge dimensions
    const badgeRadius = 22.0;
    const pointerHeight = 8.0;
    const pointerWidth = 12.0;

    final badgeCenter = Offset(position.dx, position.dy - 15);

    // Draw badge with pointer
    final badgePath = Path();

    // Circle
    badgePath.addOval(
      Rect.fromCircle(center: badgeCenter, radius: badgeRadius),
    );

    // Pointer
    final pointerPath = Path();
    pointerPath.moveTo(
      badgeCenter.dx - pointerWidth / 2,
      badgeCenter.dy + badgeRadius - 2,
    );
    pointerPath.lineTo(
      badgeCenter.dx,
      badgeCenter.dy + badgeRadius + pointerHeight,
    );
    pointerPath.lineTo(
      badgeCenter.dx + pointerWidth / 2,
      badgeCenter.dy + badgeRadius - 2,
    );
    pointerPath.close();

    badgePath.addPath(pointerPath, Offset.zero);

    // Draw badge shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(badgePath.shift(const Offset(0, 2)), shadowPaint);

    // Draw badge background
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(badgePath, bgPaint);

    // Draw badge border
    final borderPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(badgePath, borderPaint);

    // Draw time text
    final textPainter = TextPainter(
      text: TextSpan(
        text: timeStr,
        style: const TextStyle(
          color: AppColors.primaryBlackTextColor,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        badgeCenter.dx - textPainter.width / 2,
        badgeCenter.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for sleep stages line chart
class SleepStagesPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  SleepStagesPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    final circleStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final points = <Offset>[];
    const topPadding = 50.0;
    const bottomPadding = 20.0;
    final chartHeight = size.height - topPadding - bottomPadding;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final time = data[i]['time'] as double;
      // Map 0-5h range to chart height
      final y = topPadding + (chartHeight - (time / 5.0) * chartHeight);
      points.add(Offset(x, y));
    }

    // Draw fill
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height - bottomPadding);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height - bottomPadding);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw circles and badge
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 8, circleStrokePaint);
      canvas.drawCircle(points[i], 5, circlePaint);

      if (data[i]['isToday'] == true) {
        _drawBadge(canvas, points[i], data[i]['time'] as double);
      }
    }
  }

  void _drawBadge(Canvas canvas, Offset position, double time) {
    final h = time.floor();
    final m = ((time - h) * 60).round();
    final timeStr = '${h}h ${m}m';

    const badgeRadius = 22.0;
    const pointerHeight = 8.0;
    const pointerWidth = 12.0;

    final badgeCenter = Offset(position.dx, position.dy - 40);

    final badgePath = Path();
    badgePath.addOval(
      Rect.fromCircle(center: badgeCenter, radius: badgeRadius),
    );

    final pointerPath = Path();
    pointerPath.moveTo(
      badgeCenter.dx - pointerWidth / 2,
      badgeCenter.dy + badgeRadius - 2,
    );
    pointerPath.lineTo(
      badgeCenter.dx,
      badgeCenter.dy + badgeRadius + pointerHeight,
    );
    pointerPath.lineTo(
      badgeCenter.dx + pointerWidth / 2,
      badgeCenter.dy + badgeRadius - 2,
    );
    pointerPath.close();

    badgePath.addPath(pointerPath, Offset.zero);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(badgePath.shift(const Offset(0, 2)), shadowPaint);

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(badgePath, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(badgePath, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: timeStr,
        style: const TextStyle(
          color: AppColors.primaryBlackTextColor,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        badgeCenter.dx - textPainter.width / 2,
        badgeCenter.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for snore time bar chart
class SnoreTimePainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  SnoreTimePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    const topPadding = 50.0;
    const bottomPadding = 20.0;
    final chartHeight = size.height - topPadding - bottomPadding;
    final barWidth = size.width / (data.length * 2 - 1);

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final hours = item['hours'] as double;
      final isToday = item['isToday'] as bool;

      // Calculate bar height (max 2.5h)
      final barHeight = (hours / 2.5) * chartHeight;

      final x =
          i * (size.width / data.length) +
          (size.width / data.length - barWidth) / 2;
      final y = topPadding + (chartHeight - barHeight);

      paint.color = isToday
          ? const Color(0xFF6366F1)
          : const Color(0xFF6366F1).withOpacity(0.4);

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
      );
      canvas.drawRRect(rrect, paint);

      if (isToday) {
        _drawBadge(canvas, Offset(x + barWidth / 2, y), hours);
      }
    }
  }

  void _drawBadge(Canvas canvas, Offset position, double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    final timeStr = '${h}h ${m}m';

    const badgeRadius = 22.0;
    const pointerHeight = 8.0;
    const pointerWidth = 12.0;

    final badgeCenter = Offset(position.dx, position.dy - 15);

    final badgePath = Path();
    badgePath.addOval(
      Rect.fromCircle(center: badgeCenter, radius: badgeRadius),
    );

    final pointerPath = Path();
    pointerPath.moveTo(
      badgeCenter.dx - pointerWidth / 2,
      badgeCenter.dy + badgeRadius - 2,
    );
    pointerPath.lineTo(
      badgeCenter.dx,
      badgeCenter.dy + badgeRadius + pointerHeight,
    );
    pointerPath.lineTo(
      badgeCenter.dx + pointerWidth / 2,
      badgeCenter.dy + badgeRadius - 2,
    );
    pointerPath.close();

    badgePath.addPath(pointerPath, Offset.zero);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(badgePath.shift(const Offset(0, 2)), shadowPaint);

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(badgePath, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(badgePath, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: timeStr,
        style: const TextStyle(
          color: AppColors.primaryBlackTextColor,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        badgeCenter.dx - textPainter.width / 2,
        badgeCenter.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
