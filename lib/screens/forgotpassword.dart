
import 'package:easy_agent/controllers/logincontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final LoginController controller = Get.find();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _agentEmailController;
  FocusNode agentEmailFocusNode = FocusNode();


  @override
  void initState(){
    super.initState();
    _agentEmailController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    _agentEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back,size:30,color:secondaryColor)
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/easy.png",width: 100,height: 100,),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _agentEmailController,
                      focusNode: agentEmailFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: InputDecoration(
                          labelStyle: const TextStyle(color: secondaryColor),
                          labelText: "Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: secondaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12))
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter code";
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30,),
                  RawMaterialButton(
                    onPressed: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {

                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    elevation: 8,
                    fillColor: secondaryColor,
                    splashColor: Colors.amberAccent,
                    child: const Text(
                      "Send",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

