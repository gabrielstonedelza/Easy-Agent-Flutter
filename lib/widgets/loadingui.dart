import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';

class LoadingUi extends StatelessWidget {
  const LoadingUi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Lottie.asset("assets/images/98432-loading.json"),
        ),
        const SizedBox(height: 30,),
        const Center(
          child: Text("Processing",style: TextStyle(fontWeight: FontWeight.bold),),
        )
      ],
    );
  }
}
