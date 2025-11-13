import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _sensitivity = 0.6;
  bool _saveToCloud = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            ListTile(
              title: const Text('Sound sensitivity'),
              subtitle: Slider(value: _sensitivity, onChanged: (v) => setState(() => _sensitivity = v)),
            ),
            SwitchListTile(title: const Text('Save to cloud'), value: _saveToCloud, onChanged: (v) => setState(() => _saveToCloud = v)),
            SwitchListTile(title: const Text('Dark mode'), value: _darkMode, onChanged: (v) => setState(() => _darkMode = v)),
            ListTile(title: const Text('About & Privacy Policy'), onTap: () {}),
          ],
        ),
      ),
    );
  }
}
