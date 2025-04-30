import 'package:ext/firebase_options.dart';
import 'package:ext/global.dart';
import 'package:ext/models/loyalty_card.dart';
import 'package:ext/pages/login_page.dart';
import 'package:ext/repositories/firebase_loyalty_card_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ext/blocs/dashboard/dashboard_bloc.dart';
import 'package:ext/pages/dashboard_page.dart';
import 'package:ext/repositories/shared_pref_loyalty_card_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, like Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Handling a background message: ${message.messageId}");
  // Handle the background message here
  // You could show a local notification, update data, etc.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions.currentPlatform); // Initialize Firebase first

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (kIsWeb) {
    // Web specific initialization if needed
    Global.init(FirebaseLoyaltyCardRepository());
  } else {
    // Mobile specific initialization
    Global.init(SharedPrefLoyaltyCardRepo());
    
    // Request notification permissions for mobile platforms
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get FCM Token
    final fcmToken = await messaging.getToken();
    print("FCM Token: $fcmToken");
    // You would typically send this token to your server

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // You could display an in-app notification/alert here
      }
    });
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final id = prefs.getString("userId");
  bool isAuth = false;
  if (!kIsWeb) {
    prefs.setString("userId", "TMP_ID");
    isAuth = true;
  }
  if (id != null && id.isNotEmpty) {
    isAuth = true;
  }
  runApp(MyApp(isAuth: isAuth));
}

class MyApp extends StatelessWidget {
  final bool isAuth;
  const MyApp({super.key, this.isAuth = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(LoadDashboard()),
      child: MaterialApp(
        title: 'Everyday Rewards Inc.',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: isAuth ? const DashboardPage() : const LoginPage(),
      ),
    );
  }
}
