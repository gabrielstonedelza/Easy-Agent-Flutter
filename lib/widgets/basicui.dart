import 'package:flutter/material.dart';

import '../constants.dart';
import 'getonlineimage.dart';

Widget myBasicWidget(String imageName,String title,String title2){
  return SizedBox(
    width: 130,
    height: 130,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          myOnlineImage(imageName,70,70),
          const SizedBox(
            height: 10,
          ),
          Text(title,style: const TextStyle(color:Colors.black),),
          Text(title2,style: const TextStyle(color:Colors.black),),
        ],
      ),
    ),
  );
}