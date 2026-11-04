import 'package:flutter/material.dart';
import 'core/session.dart';
import 'config/app_config.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.instance.load();
  await Session.instance.saveBaseUrl(AppConfig.defaultBaseUrl);
  runApp(const MyPrivosApp());
}

class MyPrivosApp extends StatelessWidget {
  const MyPrivosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPrivos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Session.instance.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
