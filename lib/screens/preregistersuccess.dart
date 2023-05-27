import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'login.dart';

class RegisterSuccess extends StatelessWidget {
  const RegisterSuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 400,
            child: Lottie.asset("assets/images/congratulations.json"),
          ),
          const SizedBox(height: 20,),
          IconButton(
            onPressed: (){
              Get.offAll(() => const LoginView(),transition: Transition.upToDown);
            },
            icon: Image.asset("assets/images/home.png",width: 200,height: 200,),
          )
        ],
      ),
    );
  }
}
