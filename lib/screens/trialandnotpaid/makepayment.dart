import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MakeMonthlyPayment extends StatefulWidget {
  const MakeMonthlyPayment({Key? key}) : super(key: key);

  @override
  State<MakeMonthlyPayment> createState() => _MakeMonthlyPaymentState();
}

class _MakeMonthlyPaymentState extends State<MakeMonthlyPayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("assets/images/9913-payment-failed.json"),
          const Padding(
            padding: EdgeInsets.only(top:18.0,left:10,right: 10),
            child: Text("You haven't made your monthly payment yet,please pay now and access Easy Agent",style: TextStyle(fontWeight: FontWeight.bold),),
          )
        ],
      ),
    );
  }
}
