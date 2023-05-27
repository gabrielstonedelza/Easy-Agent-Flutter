import 'package:flutter/material.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

class MtnBundle extends StatefulWidget {
  const MtnBundle({Key? key}) : super(key: key);

  @override
  State<MtnBundle> createState() => _MtnBundleState();
}

class _MtnBundleState extends State<MtnBundle> {
  final List bundleType = [
    "Select Bundle Type",
    "Data Bundle",
    "Midnight Bundle",
    "Kokrokoo"
  ];

  final List purchaseType = [
    "Bundle for",
    "Self",
    "Others"
  ];

  final bundlePlans = [
    "Select Plan",
    "GHC 1 (40.92MB)",
    "GHC 3 (401.61)"
  ];

  final paymentMethods = [
    "Select payment method",
    "Airtime",
    "Mobile Money"
  ];

  var _currentSelectedBundleType = "Select Bundle Type";
  var _currentSelectedPurchaseType = "Bundle for";
  var _currentSelectedPlan = "Select Plan";
  var _currentSelectedPaymentMethod = "Select payment method";

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _customerPhoneController;
  FocusNode amountFocusNode = FocusNode();
  FocusNode customerPhoneFocusNode = FocusNode();
  late String bundleOption = "";

  Future<void> dialBuyAirtime(String customerNumber,String amount) async {
    UssdAdvanced.multisessionUssd(code: "*171*5*1*5*$amount*$customerNumber*$customerNumber#",subscriptionId: 1);
  }

  @override
  void initState(){
    super.initState();
    _amountController = TextEditingController();
    _customerPhoneController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    _amountController.dispose();
    _customerPhoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Airtime",style:TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: bundleType.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedType(newValueSelected);
                            if(newValueSelected == "Customer") {
                              setState(() {

                              });
                            }
                          },
                          value: _currentSelectedBundleType,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: bundleType.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedPurchaseType(newValueSelected);
                            if(newValueSelected == "Customer") {
                              setState(() {

                              });
                            }
                          },
                          value: _currentSelectedPurchaseType,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: bundlePlans.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedPlan(newValueSelected);
                            if(newValueSelected == "Customer") {
                              setState(() {

                              });
                            }
                          },
                          value: _currentSelectedPlan,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: paymentMethods.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedPaymentMethod(newValueSelected);
                            if(newValueSelected == "Customer") {
                              setState(() {

                              });
                            }
                          },
                          value: _currentSelectedPaymentMethod,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _customerPhoneController,
                      focusNode: customerPhoneFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Customer's number",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter customer's number";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _amountController,
                      focusNode: amountFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(

                          labelText: "Amount",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter amount";
                        }
                        return null;
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
                        dialBuyAirtime(_customerPhoneController.text.trim(),_amountController.text.trim());
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    elevation: 8,
                    fillColor: Colors.amber,
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
          )
        ],
      ),
    );
  }

  void _onDropDownItemSelectedType(newValueSelected) {
    setState(() {
      _currentSelectedBundleType = newValueSelected;
    });
  }
  void _onDropDownItemSelectedPurchaseType(newValueSelected) {
    setState(() {
      _currentSelectedPurchaseType = newValueSelected;
    });
  }
  void _onDropDownItemSelectedPlan(newValueSelected) {
    setState(() {
      _currentSelectedPlan = newValueSelected;
    });
  }
  void _onDropDownItemSelectedPaymentMethod(newValueSelected) {
    setState(() {
      _currentSelectedPaymentMethod = newValueSelected;
    });
  }
}
