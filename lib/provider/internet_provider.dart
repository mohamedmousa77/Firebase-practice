// import 'dart:js_util';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetProvider extends ChangeNotifier{
  bool hasInternet = false;

  InternetProvider () {
    checkInternetConnection();
  }

  Future checkInternetConnection() async {
    var result= Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none){
      hasInternet = false;
    }else {
      hasInternet = true;
    }
    notifyListeners();
  }

}