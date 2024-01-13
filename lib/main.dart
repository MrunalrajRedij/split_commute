import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:split_commute/Screens/loginScreen.dart';
import 'package:split_commute/config/routes.dart';
import 'package:split_commute/firebase_options.dart';
import 'package:split_commute/screens/homeScreen.dart';
import 'package:split_commute/config/palette.dart' as palette;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: const MaterialColor(
              palette.primaryColorInt,
              palette.persianColorMap,
            ),
            colorScheme: ColorScheme.fromSeed(seedColor: palette.primaryColor),
            useMaterial3: true,
          ),
          home: const MyHomePage(),
          routes: getRoutes(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late User? _user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    //get user from firebase auth for further validation
    final FirebaseAuth auth = FirebaseAuth.instance;
    _user = auth.currentUser;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : _user == null
            ? const LoginScreen() // if user is empty redirect to AppInfoScreen
            : const HomeScreen(); //
  }
}
