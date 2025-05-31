import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:scribblr/store/app_store.dart';
import 'package:scribblr/utils/colors.dart';
import 'package:scribblr/screens/auth/sign_in.dart';
import 'package:scribblr/screens/dashboard/dashboard.dart';
import 'utils/app_theme.dart';

AppStore appStore = AppStore();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize(); // Ensure SharedPreferences is initialized

  runApp(
    Provider<AppStore>(
      create: (_) => AppStore(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    return _seen;
  }

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

    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scribblr',
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
