import 'package:flutter/material.dart';
import 'package:jammerz/views/HomeScreen.dart';
import 'package:jammerz/views/StartScreen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/User.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/musicians.jpg"), context);
    precacheImage(AssetImage("assets/images/concert.jpg"), context);
    precacheImage(AssetImage("assets/images/silhouette.jpg"), context);

    Provider.of<UserProvider>(context).obtainLocation();
    var user = Provider.of<FirebaseUser>(context);
    return user != null ? HomeScreen(uid: user.uid) : StartScreen();
  }
}
