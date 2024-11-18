import 'package:cuantrack/routes/routes.dart';
import 'package:cuantrack/services/theme_services.dart';
import 'package:cuantrack/splashscreen.dart';
import 'package:cuantrack/theme/theme.dart';
import 'package:cuantrack/views/screens/authentication/login.dart';
import 'package:cuantrack/views/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init(); // Inisialisasi storage
  ThemeService().loadThemeFromStorage(); // Load tema dari storage
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CuanTrack',
      debugShowCheckedModeBanner: false,
      theme: CTAppTheme.lightTheme,
      darkTheme: CTAppTheme.darkTheme,
      themeMode: ThemeService().theme, // Gunakan tema dari ThemeService
      initialRoute: Routes.getHomeRoute(),
      getPages: Routes.getPages(),
      home: const SplashToNextScreen(),
    );
  }
}

class SplashToNextScreen extends StatefulWidget {
  const SplashToNextScreen({super.key});

  @override
  State<SplashToNextScreen> createState() => _SplashToNextScreenState();
}

class _SplashToNextScreenState extends State<SplashToNextScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      // Periksa status login pengguna
      Get.off(() => StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                return const HomeScreen(); // Pengguna sudah login
              } else {
                return const LoginScreen(); // Pengguna belum login
              }
            },
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
