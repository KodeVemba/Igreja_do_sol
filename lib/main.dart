// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase_options.dart';
import 'screens/admin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';

final ColorScheme peacefulSkyScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(
    0xFF496989,
  ), // Muted Blue for App background , main buttons , active elements
  onPrimary: Colors.white, // text on elevated button
  secondary: Color(
    0xFFA8C5DA,
  ), // Sky blue, Chips , FAB , toggle buttons , active icons
  onSecondary: Colors.black, // Icons in a FAB
  background: Color(0xFFF0F4F8), // Cloud white for Scaffold background
  onBackground: Color(0xFF263238),
  surface: Color(
    0xFFE1ECF2,
  ), // Soft blue-gray for Card , bottom sheet  Dialog backgoround
  onSurface: Color(0xFF263238), // Card content , dialog text
  error: Colors.red, // Error message , delete button
  onError: Colors.white,
);

final ThemeData peacefulSkyTheme =
    ThemeData.from(colorScheme: peacefulSkyScheme).copyWith(
      scaffoldBackgroundColor: Color(0xFFF0F4F8),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF263238)),
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF263238),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF496989),
        foregroundColor: Colors.white,
      ),
    );

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Church Scheduler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: peacefulSkyScheme),
      initialRoute: '/admin',
      routes: {
        '/login': (context) => const MyLoginPage(),
        '/admin': (context) => const MyAdminPage(),
        '/home': (context) => const MyHomePage(),
        '/sign up': (context) => const MySignUpPage(),
      },
    );
  }
}
