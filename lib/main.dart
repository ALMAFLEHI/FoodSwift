import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'app/router.dart';
import 'app/theme/color_scheme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> setupFCM() async {
  // Request permission (Android 13+ requires runtime)
  await FirebaseMessaging.instance.requestPermission();

  // Define a high importance notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  // Create the notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // Initialize the local notifications plugin
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final android = notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFCM(); // ✅ Init FCM after Firebase
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('🔔 FCM Token: $fcmToken');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodSwift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: AppColors.textDark,
          displayColor: AppColors.textDark,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
