import 'package:cuantrack/routes/routes.dart';
import 'package:cuantrack/services/app_theme.dart';
import 'package:cuantrack/services/theme_service.dart';
import 'package:cuantrack/splashscreen.dart';
import 'package:cuantrack/views/screens/authentication/login.dart';
import 'package:cuantrack/views/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeService themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CuanTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Tema terang
      darkTheme: AppTheme.darkTheme, // Tema gelap
      themeMode: themeService.theme, // Ambil tema dari ThemeService
      initialRoute: Routes.getHomeRoute(), // Route awal
      getPages: Routes.getPages(), // Daftar route
      home: const SplashToNextScreen(), // Tampilan awal splash screen
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

    // Tunda selama 3 detik lalu cek status login pengguna
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                return HomeScreen(); // Pengguna sudah login
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
