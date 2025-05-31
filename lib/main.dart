import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:scribblr/store/app_store.dart';
import 'package:scribblr/utils/colors.dart';
import 'package:scribblr/screens/auth/sign_in.dart';
import 'package:scribblr/screens/dashboard/dashboard.dart'; // ✅ Import Event Screen
import 'utils/app_theme.dart';

AppStore appStore = AppStore();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize(); // Ensure SharedPreferences is initialized

  await setupOneSignal(); // ✅ Initialize OneSignal

  runApp(
    Provider<AppStore>(
      create: (_) => AppStore(),
      child: const MyApp(),
    ),
  );
}

Future<void> setupOneSignal() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.info); // ✅ Enable Debug Logging

  OneSignal.initialize(
      "dcce1a00-1229-4d9a-a882-ffe6605dddd3"); // ✅ Replace with your OneSignal App ID

  OneSignal.Notifications.requestPermission(
      true); // ✅ Ask for notification permission (iOS)

  // **📌 Listen for push subscription state changes**
  OneSignal.User.pushSubscription.addObserver((state) {
    print("🔔 Push Subscription State Changed");
    print("🔔 User ID: ${state.current.id}");
    print("🔔 Push Token: ${state.current.token}");
  });

  // **📌 Fetch Initial Subscription State**
  var pushSubscription = OneSignal.User.pushSubscription;
  print("🔔 Initial Push Token: ${pushSubscription.token}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isUserLoggedIn() async {
    String? userData = getStringAsync("user_data", defaultValue: "");
    return userData.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          appStore.isDarkMode ? scaffoldDarkColor : scaffoldPrimaryLight,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    ));

    // ✅ Listen for Notification Clicks
    OneSignal.Notifications.addClickListener((event) {
      if (event.notification.additionalData != null) {
        String? eventId = event.notification.additionalData!['event_id'];

        if (eventId != null) {
          // print("🔔 Opening Event ID: $eventId");

          // // ✅ Navigate to EventScreen when the notification is tapped
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => EventScreen(eventId: eventId)),
          // );
        }
      }
    });

    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dorm Application',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: FutureBuilder<bool>(
          future: isUserLoggedIn(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              if (snapshot.hasData && snapshot.data == true) {
                return DashboardScreen(); // Redirect to Dashboard if logged in
              } else {
                return const SignInScreen(); // Show Sign-in screen if not logged in
              }
            }
          },
        ),
      ),
    );
  }
}
