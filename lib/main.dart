import 'package:flutter/material.dart';
import 'package:job_findr/services/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:job_findr/views/auth_gate.dart';
//import 'package:job_findr/views/constants/constants.dart'; --not needed?
import 'package:provider/provider.dart';
import 'package:job_findr/services/auth.dart';
import 'package:job_findr/models/user.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
//import 'package:job_findr/views/home/job_seeker_profileview.dart'; --not needed?

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // code needed to connect to the firebase servers
  // Check if Firebase has already been initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
        value: AuthService().user,
        initialData: null,
        child: MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.white,
            scaffoldBackgroundColor: Colors.white,
          ),
          debugShowCheckedModeBanner: false,
          home: AuthGate(),
        ));
  }
}
