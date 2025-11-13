import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _requesting = false;

  Future<void> _requestMic() async {
    setState(() => _requesting = true);
    final status = await Permission.microphone.request();
    setState(() => _requesting = false);

    if (status.isGranted) {
      context.go('/tracking');
    } else {
      // show simple dialog
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Permission needed'),
          content: const Text('Microphone permission is required to detect snoring.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(title: const Text('Permissions')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, size: 80.w, color: const Color(0xFF4A6CF7)),
            SizedBox(height: 16.h),
            Text('Microphone Permission', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text(
              'We use your microphone to detect snoring sounds during sleep. No voice is stored without your consent.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF8A8A8A)),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _requesting ? null : _requestMic,
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 52.h)),
              child: _requesting ? const CircularProgressIndicator() : const Text('Allow Microphone'),
            ),
          ],
        ),
      ),
    );
  }
}
