import 'dart:async';

import 'package:authentication_firebase/provider/internet_provider.dart';
import 'package:authentication_firebase/provider/sign_in_provider.dart';
import 'package:authentication_firebase/screens/home_screen.dart';
import 'package:authentication_firebase/utils/snak_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey _scaffoldkey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookControlled =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldkey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 90, right: 40, left: 40, bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        Image(
                          image: AssetImage(Config.appLogo),
                          height: 80,
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 20),
                        const Text('Welcome to flutter authentication',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 25)),
                        const SizedBox(height: 10),
                        Text('Flutter authentication with provider',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[600])),
                      ],
                    )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedLoadingButton(
                      controller: googleController,
                      successColor: Colors.red,
                      color: Colors.red,
                      elevation: 0,
                      borderRadius: 25,
                      width: MediaQuery.of(context).size.width * 0.80,
                      onPressed: () {
                        handingGoogle();
                      },
                      child: const Wrap(
                        children: [
                          Icon(FontAwesomeIcons.google,
                              size: 20, color: Colors.white),
                          SizedBox(width: 25),
                          Text(
                            'SignIn with google',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    RoundedLoadingButton(
                      controller: facebookControlled,
                      successColor: Colors.blue,
                      color: Colors.blue,
                      elevation: 0,
                      borderRadius: 25,
                      width: MediaQuery.of(context).size.width * 0.80,
                      onPressed: () {},
                      child: const Wrap(
                        children: [
                          Icon(FontAwesomeIcons.facebook,
                              size: 20, color: Colors.white),
                          SizedBox(width: 25),
                          Text(
                            'SignIn with facebook',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  // Handling google sign in min: 52:23x
  Future handingGoogle() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();
    if (ip.hasInternet == false) {
      openSnackBar(context, 'Check internet connection', Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithGoogle().then((value) {
        // When sign in is completed
        if (sp.hasError == true) {
          openSnackBar(context, sp.errorCode.toString(), Colors.red);
          googleController.reset();
        } else {
          // check whether the user exist or not
          sp.checkUserExist().then((value) async {
            if (value == true) {
              // means that user exist
            } else {
              // user not exist
              sp.saveDataToFirestore().then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.signIn().then((value) {
                    googleController.success();
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));
              })));
            }
          });
        }
      });
    }
  }




}
