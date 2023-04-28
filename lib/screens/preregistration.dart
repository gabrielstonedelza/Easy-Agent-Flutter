
import 'package:easy_agent/controllers/logincontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';

import '../constants.dart';
import '../widgets/loadingui.dart';


class AgentPreRegistration extends StatefulWidget {
  const AgentPreRegistration({Key? key}) : super(key: key);

  @override
  State<AgentPreRegistration> createState() => _AgentPreRegistrationState();
}

class _AgentPreRegistrationState extends State<AgentPreRegistration> {
  final LoginController controller = Get.find();
  bool isPosting = false;

  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _agentNameController;
  late final TextEditingController _agentPhoneNumberController;
  late final TextEditingController _agentDigitalAddressController;
  FocusNode agentNameFocusNode = FocusNode();
  FocusNode agentPhoneNumberFocusNode = FocusNode();
  FocusNode agentDigitalAddressFocusNode = FocusNode();


  @override
  void initState(){
    super.initState();
    _agentNameController = TextEditingController();
    _agentPhoneNumberController = TextEditingController();
    _agentDigitalAddressController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    _agentNameController.dispose();
    _agentPhoneNumberController.dispose();
    _agentDigitalAddressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          const SizedBox(height: 20,),
          const Center(
            child: Text("Enter your details and we get back to you.",style:TextStyle(fontWeight: FontWeight.bold)),
          ),
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
                      controller: _agentNameController,
                      focusNode: agentNameFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Full Name"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter full name";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _agentPhoneNumberController,
                      focusNode: agentPhoneNumberFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Phone Number"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter phone";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _agentDigitalAddressController,
                      focusNode: agentDigitalAddressFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Digital Address"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter digital address";
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30,),
                  isPosting  ? const LoadingUi() :
                  NeoPopTiltedButton(
                    isFloating: true,
                    onTapUp: () {
                      _startPosting();
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        controller.addAgentPreRegistration(_agentNameController.text.trim(),_agentPhoneNumberController.text.trim(),_agentDigitalAddressController.text.trim());
                      }
                    },
                    decoration: const NeoPopTiltedButtonDecoration(
                      color: secondaryColor,
                      plunkColor: Color.fromRGBO(255, 235, 52, 1),
                      shadowColor: Color.fromRGBO(36, 36, 36, 1),
                      showShimmer: true,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 70.0,
                        vertical: 15,
                      ),
                      child: Text('Send',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration(String text) {
    return InputDecoration(
      labelStyle: const TextStyle(color: secondaryColor),
      labelText: text,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: secondaryColor, width: 2),
          borderRadius: BorderRadius.circular(12)),
    );
  }
}

