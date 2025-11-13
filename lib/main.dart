import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/hive/hive_service.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: SleepifyApp()));
}

class SleepifyApp extends StatelessWidget {
  const SleepifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Sleepify',
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
