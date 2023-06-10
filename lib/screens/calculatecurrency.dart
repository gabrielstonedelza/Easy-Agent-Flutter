import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';

class CalculateCurrencies extends StatefulWidget {
  const CalculateCurrencies({Key? key}) : super(key: key);

  @override
  State<CalculateCurrencies> createState() => _CalculateCurrenciesState();
}

class _CalculateCurrenciesState extends State<CalculateCurrencies> {
  late final TextEditingController _d200Controller;
  late final TextEditingController _d100Controller;
  late final TextEditingController _d50Controller;
  late final TextEditingController _d20Controller;
  late final TextEditingController _d10Controller;
  late final TextEditingController _d5Controller;
  late final TextEditingController _d2Controller;
  late final TextEditingController _d1Controller;

  late double d200 = 0;
  late double d100 = 0;
  late double d50 = 0;
  late double d20 = 0;
  late double d10 = 0;
  late double d5 = 0;
  late double d2 = 0;
  late double d1 = 0;
  late double total = 0;

  FocusNode d200FocusNode = FocusNode();
  FocusNode d100FocusNode = FocusNode();
  FocusNode d50FocusNode = FocusNode();
  FocusNode d20FocusNode = FocusNode();
  FocusNode d10FocusNode = FocusNode();
  FocusNode d5FocusNode = FocusNode();
  FocusNode d2FocusNode = FocusNode();
  FocusNode d1FocusNode = FocusNode();

  bool isCalculated = false;


  @override
  void initState() {
    super.initState();

    _d200Controller = TextEditingController();
    _d100Controller = TextEditingController();
    _d50Controller = TextEditingController();
    _d20Controller = TextEditingController();
    _d10Controller = TextEditingController();
    _d5Controller = TextEditingController();
    _d2Controller = TextEditingController();
    _d1Controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _d200Controller.dispose();
    _d100Controller.dispose();
    _d50Controller.dispose();
    _d20Controller.dispose();
    _d10Controller.dispose();
    _d5Controller.dispose();
    _d2Controller.dispose();
    _d1Controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text("Calculate Notes"),
        backgroundColor: secondaryColor,
        actions: [
          IconButton(
            onPressed: (){
              setState(() {
                isCalculated = false;
                _d200Controller.text = "";
                d200 = 0;
                _d100Controller.text = "";
                d100 = 0;
                _d50Controller.text = "";
                d50 = 0;
                _d20Controller.text = "";
                d20 = 0;
                _d10Controller.text = "";
                d10 = 0;
                _d5Controller.text = "";
                d5 = 0;
                _d2Controller.text = "";
                d2 = 0;
                _d1Controller.text = "";
                d1 = 0;
              });
            },
            icon: const Icon(Icons.refresh,size: 30,),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0),
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                double dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d200 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = double.parse(value) * 200;
                                    d200 = dt;
                                  });
                                }
                              },
                              focusNode: d200FocusNode,
                              controller: _d200Controller,
                              cursorColor: secondaryColor,
                              cursorRadius:
                              const Radius.elliptical(
                                  10, 10),
                              cursorWidth: 10,
                              decoration:
                              buildInputDecoration(
                                  "200 GHC Notes"),
                              keyboardType:
                              TextInputType.number,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 12),
                              child: Text(
                                d200.toString(),
                                style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0),
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (value) {

                                double dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d100 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = double.parse(value) * 100;
                                    d100 = dt;
                                  });
                                }
                              },
                              controller: _d100Controller,
                              focusNode: d100FocusNode,
                              cursorColor: secondaryColor,
                              cursorRadius:
                              const Radius.elliptical(
                                  10, 10),
                              cursorWidth: 10,
                              decoration:
                              buildInputDecoration(
                                  "100 GHC Notes"),
                              keyboardType:
                              TextInputType.number,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 12),
                              child: Text(
                                d100.toString(),
                                style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0),
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                // var dt =
                                //     int.parse(value) * 50;
                                // setState(() {
                                //   d50 = dt;
                                // });

                                double dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d50 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = double.parse(value) * 50;
                                    d50 = dt;
                                  });
                                }
                              },
                              focusNode: d50FocusNode,
                              controller: _d50Controller,
                              cursorColor: secondaryColor,
                              cursorRadius:
                              const Radius.elliptical(
                                  10, 10),
                              cursorWidth: 10,
                              decoration:
                              buildInputDecoration(
                                  "50 GHC Notes"),
                              keyboardType:
                              TextInputType.number,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 12),
                              child: Text(
                                d50.toString(),
                                style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0),
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                // var dt =
                                //     int.parse(value) * 20;
                                // setState(() {
                                //   d20 = dt;
                                // });
                                //
                                double dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d20 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = double.parse(value) * 20;
                                    d20 = dt;
                                  });
                                }
                              },
                              focusNode: d20FocusNode,
                              controller: _d20Controller,
                              cursorColor: secondaryColor,
                              cursorRadius:
                              const Radius.elliptical(
                                  10, 10),
                              cursorWidth: 10,
                              decoration:
                              buildInputDecoration(
                                  "20 GHC Notes"),
                              keyboardType:
                              TextInputType.number,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 12),
                              child: Text(
                                d20.toString(),
                                style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0),
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                // var dt =
                                //     int.parse(value) * 10;
                                // setState(() {
                                //   d10 = dt;
                                // });
                                double dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d10 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = double.parse(value) * 10;
                                    d10 = dt;
                                  });
                                }
                              },
                              focusNode: d10FocusNode,
                              controller: _d10Controller,
                              cursorColor: secondaryColor,
                              cursorRadius:
                              const Radius.elliptical(
                                  10, 10),
                              cursorWidth: 10,
                              decoration:
                              buildInputDecoration(
                                  "10 GHC Notes"),
                              keyboardType:
                              TextInputType.number,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 12),
                              child: Text(
                                d10.toString(),
                                style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0),
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                // var dt =
                                //     int.parse(value) * 5;
                                // setState(() {
                                //   d5 = dt;
                                // });

                                double dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d5 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = double.parse(value) * 5;
                                    d5 = dt;
                                  });
                                }
                              },
                              focusNode: d5FocusNode,
                              controller: _d5Controller,
                              cursorColor: secondaryColor,
                              cursorRadius:
                              const Radius.elliptical(
                                  10, 10),
                              cursorWidth: 10,
                              decoration:
                              buildInputDecoration(
                                  "5 GHC Notes"),
                              keyboardType:
                              TextInputType.number,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 12),
                              child: Text(
                                d5.toString(),
                                style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0),
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                // var dt =
                                //     int.parse(value) * 2;
                                // setState(() {
                                //   d2 = dt;
                                // });
                                double dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d2 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = double.parse(value) * 2;
                                    d2 = dt;
                                  });
                                }

                              },
                              focusNode: d2FocusNode,
                              controller: _d2Controller,
                              cursorColor: secondaryColor,
                              cursorRadius:
                              const Radius.elliptical(
                                  10, 10),
                              cursorWidth: 10,
                              decoration:
                              buildInputDecoration(
                                  "2GHC Notes"),
                              keyboardType:
                              TextInputType.number,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 12),
                              child: Text(
                                d2.toString(),
                                style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0),
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                // var dt =
                                //     int.parse(value) * 1;
                                // setState(() {
                                //   d1 = dt;
                                // });
                                double dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d1 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = double.parse(value) * 1;
                                    d1 = dt;
                                  });
                                }
                              },
                              focusNode: d1FocusNode,
                              controller: _d1Controller,
                              cursorColor: secondaryColor,
                              cursorRadius:
                              const Radius.elliptical(
                                  10, 10),
                              cursorWidth: 10,
                              decoration:
                              buildInputDecoration(
                                  "1 GHC Notes"),
                              keyboardType:
                              TextInputType.number,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 12),
                              child: Text(
                                d1.toString(),
                                style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                RawMaterialButton(
                  fillColor: secondaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                  ),
                  onPressed: (){

                    FocusScopeNode currentFocus =
                    FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    double mainTotal = d200 +
                        d100 +
                        d50 +
                        d20 +
                        d10 +
                        d5 +
                        d2 +
                        d1;

                    setState(() {
                      total = mainTotal;
                      isCalculated = true;
                    });

                  },child: const Text("Calculate",style: TextStyle(color: defaultWhite,fontWeight: FontWeight.bold),),
                ),
                isCalculated ? Padding(
                  padding: const EdgeInsets.only(top:18.0),
                  child: Center(
                    child: Text(
                      "TOTAL: $total",
                      style: const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.red,
                          fontSize: 20),
                    ),
                  ),
                ) : Container()
              ],
            ),
          )
        ],
      ),
    ));
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
