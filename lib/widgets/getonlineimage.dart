import 'package:flutter/material.dart';

Widget myOnlineImage(String imageLink,double h,double w){
  return Container(
    height: h,
    width: w,
    decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(imageLink)
        )
    ),
  );
}