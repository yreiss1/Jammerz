import 'package:flutter/material.dart';
import 'package:jammerz/models/Post.dart';
import 'package:jammerz/models/User.dart';
import 'package:jammerz/views/DiscoverScreen.dart';
import 'package:jammerz/views/EditProfileScreen.dart';
import 'package:jammerz/views/LandingScreen.dart';
import 'package:jammerz/views/OnboardingScreens/ImageCapture.dart';
import 'package:jammerz/views/ProfileScreen.dart';
import 'package:jammerz/views/SearchScreen.dart';
import 'package:jammerz/views/UploadScreens/EventUploadScreen.dart';
import 'package:jammerz/views/UploadScreens/PostUploadScreen.dart';
import './views/HomeScreen.dart';
import './views/StartScreen.dart';
import './models/Event.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './AuthService.dart';

void main() => runApp(
      MyApp(),
    );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(
          value: FirebaseAuth.instance.onAuthStateChanged,
        ),
        ChangeNotifierProvider<AuthService>(
          builder: (_) {
            return AuthService();
          },
        ),
        ChangeNotifierProvider<UserProvider>(
          builder: (_) {
            return UserProvider();
          },
        ),
        ChangeNotifierProvider<PostProvider>(
          builder: (_) {
            return PostProvider();
          },
        ),
        ChangeNotifierProvider<EventProvider>(
          builder: (_) {
            return EventProvider();
          },
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bandmates',
        theme: ThemeData(
          primaryColor: Color(0xff53172c),
          accentColor: Color(0xff53172c),
          backgroundColor: Colors.white,
          fontFamily: 'Montserrat',
        ),
        home: LandingScreen(),
        routes: {
          // Here we add routes to different pages
          StartScreen.routeName: (ctx) => StartScreen(),
          ImageCapture.routeName: (ctx) => ImageCapture(),
          HomeScreen.routeName: (ctx) => HomeScreen(),
          SearchScreen.routeName: (ctx) => SearchScreen(),
          ProfileScreen.routeName: (ctx) =>
              ProfileScreen(ModalRoute.of(ctx).settings.arguments),
          DiscoverScreen.routeName: (ctx) =>
              DiscoverScreen(ModalRoute.of(ctx).settings.arguments),
          PostUploadScreen.routeName: (ctx) => PostUploadScreen(),
          EventUploadScreen.routeName: (ctx) => EventUploadScreen(),
          EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
        },
      ),
    );
  }
}
