import 'package:flutter/material.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

import 'dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: const Dashboard(),
      duration: 11000,
      imageSize: 300,
      imageSrc: "assets/images/easy-peasy.gif",
      text: "Easy Agent",
      textType: TextType.TyperAnimatedText,
      textStyle: const TextStyle(
          fontSize: 30.0,
          color: Colors.amber
      ),
      backgroundColor: Colors.white,
    );
  }
}
