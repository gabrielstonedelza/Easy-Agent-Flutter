import 'package:flutter/material.dart';

import '../constants.dart';

class LoadingUi extends StatelessWidget {
  const LoadingUi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        strokeWidth: 5,
        backgroundColor: primaryColor,
        valueColor: AlwaysStoppedAnimation<Color>(
            secondaryColor
        ),
      ),
    );
  }
}
