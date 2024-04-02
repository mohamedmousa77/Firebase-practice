import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInProvider extends ChangeNotifier {
  // Instance of firebaseAuth, facebook, google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isSignIn = false;

  bool hasError = false;
  String? errorCode;
  String? provider;
  String? uid;
  String? email;
  String? name;
  String? imgUrl;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    isSignIn = s.getBool('signed-in') ?? false;
    notifyListeners();
  }

  Future signIn() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('signed-in', true);
    isSignIn = true;
    notifyListeners();
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      // execute our authentication
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);

        // signing to firebase user instance
        final User userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user!;

        // save all user values
        name = userDetails.displayName;
        email = userDetails.email;
        imgUrl = userDetails.photoURL;
        uid = userDetails.uid;
        provider = 'GOOGLE';
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'account-already-exist':
            errorCode = 'You already have an account. use correct credential';
            hasError = true;
            notifyListeners();
            break;

          case 'null':
            errorCode = 'Unexpected error while trying to sign you in';
            hasError = true;
            notifyListeners();
            break;

          default:
            errorCode = e.toString();
            hasError = true;
            notifyListeners();
            break;
        }
      }
    } else {
      hasError = true;
      notifyListeners();
    }
  }

  // Get Data from firestore
  Future getUserDataFromFirestore() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) => {
              uid = snapshot['uid'],
              name = snapshot['name'],
              email = snapshot['email'],
              imgUrl = snapshot['img-url'],
              provider = snapshot['provider']
            });
  }

  Future saveDataToFirestore () async {
    final DocumentReference reference = FirebaseFirestore.instance.collection('user').doc('uid');
    await reference.set({
      'email': email,
      'name': name,
      'uid': uid,
      'img-url': imgUrl,
      'provider':provider
    });
    notifyListeners();
  }

  Future saveDataToSharedPreferences() async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('name', name!);
    await sharedPreferences.setString('email', email!);
    await sharedPreferences.setString('uid', uid!);
    await sharedPreferences.setString('imgUrl', imgUrl!);
    await sharedPreferences.setString('provider', provider!);
    notifyListeners();
  }

  // check if user exist on cloudStore ot not
  Future<bool> checkUserExist() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();
    if (documentSnapshot.exists) {
      debugPrint('User exist');
      return true;
    } else {
      debugPrint('User not exist');
      return false;
    }
  }

  // Sign out function
  Future signOut() async {
    firebaseAuth.signOut();
    googleSignIn.signOut();
    isSignIn = false;
    notifyListeners();
    // Clear all storage
    clearStoredData();
  }

  //Clear stored data
  Future clearStoredData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }
}
