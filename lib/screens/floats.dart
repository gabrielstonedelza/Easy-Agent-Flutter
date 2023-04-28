import 'package:flutter/material.dart';

class Floats extends StatefulWidget {
  const Floats({Key? key}) : super(key: key);

  @override
  State<Floats> createState() => _FloatsState();
}

class _FloatsState extends State<Floats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Float"),
      ),
    );
  }
}