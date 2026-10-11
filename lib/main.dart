import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'providers/progress_provider.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final StorageService storage = StorageService();
  await storage.init();

  final AudioService audio = AudioService();
  audio.soundEnabled = storage.soundOn;

  runApp(AlefbaApp(storage: storage, audio: audio));
}

class AlefbaApp extends StatelessWidget {
  const AlefbaApp({super.key, required this.storage, required this.audio});

  final StorageService storage;
  final AudioService audio;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressProvider(storage, audio),
      child: MaterialApp(
        title: 'الفبای من',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('fa'),
        builder: (BuildContext context, Widget? child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const SplashPage(),
      ),
    );
  }
}
