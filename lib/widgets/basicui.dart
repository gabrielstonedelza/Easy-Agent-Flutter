import 'package:flutter/material.dart';

import '../constants.dart';
import 'getonlineimage.dart';

Widget myBasicWidget(String imageName,String title,String title2){
  return SizedBox(
    width: 120,
    height: 120,
    child: Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
      ),
      color: snackBackground,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            myOnlineImage(imageName,50,50),
            const SizedBox(
              height: 10,
            ),
            Text(title,style: const TextStyle(color:defaultWhite),),
            Text(title2,style: const TextStyle(color:defaultWhite),),
          ],
        ),
      ),
    ),
  );
}