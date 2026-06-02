import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:latinterritory/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enables background audio playback + lock screen controls on iOS & Android.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.latinterritory.radio.channel',
    androidNotificationChannelName: 'Latin Territory Radio',
    androidNotificationIcon: 'mipmap/ic_launcher',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  // Load date/time locale data for DateFormat (used in events feature).
  await initializeDateFormatting();

  // Lock orientation to portrait on phones.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
