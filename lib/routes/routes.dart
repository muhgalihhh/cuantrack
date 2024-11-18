import 'package:cuantrack/splashscreen.dart';
import 'package:cuantrack/views/screens/analysis/analysis.dart';
import 'package:cuantrack/views/screens/authentication/login.dart';
import 'package:cuantrack/views/screens/authentication/register.dart';
import 'package:cuantrack/views/screens/home/home.dart';
import 'package:cuantrack/views/screens/settings/settings.dart';
import 'package:cuantrack/views/screens/transaction/transaction.dart';
import 'package:get/get.dart';

class Routes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String homeScreen = '/home';
  static const String transactionScreen = '/transactions';
  static const String analysisScreen = '/analysis';
  static const String settingScreen = '/settings';

  // Getter untuk setiap rute agar lebih terstruktur
  static String getHomeRoute() => home;
  static String getHomeScreenRoute() => homeScreen;
  static String getLoginRoute() => login;
  static String getRegisterRoute() => register;
  static String getTransactionScreenRoute() => transactionScreen;
  static String getAnalysisScreenRoute() => analysisScreen;
  static String getSettingScreenRoute() => settingScreen;

  // Daftar semua rute
  static List<GetPage> getPages() {
    return [
      GetPage(
        name: home,
        page: () => SplashScreen(), // Splash screen sebagai halaman awal
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: homeScreen,
        page: () => HomeScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: login,
        page: () => LoginScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: register,
        page: () => RegisterScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: transactionScreen,
        page: () => TransactionScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: analysisScreen,
        page: () => AnalysisScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: settingScreen,
        page: () => SettingsScreen(),
        transition: Transition.fadeIn,
      )
    ];
  }
}
