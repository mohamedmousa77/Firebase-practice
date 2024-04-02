import 'dart:async';

import 'package:authentication_firebase/provider/sign_in_provider.dart';
import 'package:authentication_firebase/screens/home_screen.dart';
import 'package:authentication_firebase/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // Internationalize the App
  @override
  void initState() {
    final sp = context.read<SignInProvider>();
    super.initState();
    // Create a timer for 2 seconds
    Timer(const Duration(seconds: 2),  (){
      sp.isSignIn == false ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>const LoginScreen())) :
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image(
            image: AssetImage(Config.appLogo),
            height: 80,
            width: 80,
          ),
        ),
      ),
    );
  }
}
