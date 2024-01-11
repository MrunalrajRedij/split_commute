import 'package:split_commute/screens/getInfoScreen.dart';
import 'package:split_commute/screens/homeScreen.dart';
import '../screens/loginScreen.dart';

/*implemented routes which doesn't need pass any data between them
(Not all screens are present here)
Also recognises which screen is currently active for menuWidget*/
getRoutes() {
  return {
    "/LoginScreen": (context) => const LoginScreen(),
    "/HomeScreen": (context) => const HomeScreen(),
    "/GetInfoScreen": (context) => const GetInfoScreen(),
  };
}
