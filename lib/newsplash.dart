import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:easy_agent/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'constants.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  bool isAfterFiveSeconds = false;


  @override
  void initState() {
    super.initState();

    if (storage.read("token") != null) {
      uToken = storage.read("token");
      setState(() {
        hasToken = true;
      });
    }

    else{
      setState(() {
        hasToken = false;
      });
    }
    Timer(const Duration(seconds: 10), () {
      setState(() {
        isAfterFiveSeconds = true;
      });
    }
    );

    Timer(const Duration(seconds: 15), () {
      if (hasToken) {
          Get.offAll(()=> const Dashboard());
      }
      else{
        Get.offAll(()=> const LoginView());
      }
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isAfterFiveSeconds ? SlideInUp(
            animate: true,
              child: Image.asset("assets/images/forapp.png",width: 100,height: 100,)) : Lottie.asset("assets/images/peasy.json",width: 300,),
          const SizedBox(height: 20,),
          const Center(
            child: Text("Easy Agent",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: secondaryColor),),
          ),
          const SizedBox(height: 20,),
        ],
      ),
    );
  }
}
