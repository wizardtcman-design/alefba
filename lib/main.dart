import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // قفل عمودی — مناسب کودکان
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // آماده‌سازی ذخیره‌سازی و صدا
  await StorageService.instance.init();
  await AudioService.instance.init();

  runApp(const AlefbaApp());
}

class AlefbaApp extends StatelessWidget {
  const AlefbaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'آموزش کلاس اول',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('fa', 'IR'),
        // راست‌چین کامل — قلب اپ فارسی
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
