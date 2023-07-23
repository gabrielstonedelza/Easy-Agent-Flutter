import 'package:flutter/material.dart';

import '../constants.dart';


class CalculateDenominations extends StatefulWidget {
  const CalculateDenominations({Key? key}) : super(key: key);

  @override
  State<CalculateDenominations> createState() => _CalculateDenominationsState();
}

class _CalculateDenominationsState extends State<CalculateDenominations> {
  late final TextEditingController _d200Controller;
  late final TextEditingController _d100Controller;
  late final TextEditingController _d50Controller;
  late final TextEditingController _d20Controller;
  late final TextEditingController _d10Controller;
  late final TextEditingController _d5Controller;
  late final TextEditingController _d2Controller;
  late final TextEditingController _d1Controller;
  late int d200 = 0;
  late int d100 = 0;
  late int d50 = 0;
  late int d20 = 0;
  late int d10 = 0;
  late int d5 = 0;
  late int d2 = 0;
  late int d1 = 0;
  late int total = 0;
  FocusNode d200FocusNode = FocusNode();
  FocusNode d100FocusNode = FocusNode();
  FocusNode d50FocusNode = FocusNode();
  FocusNode d20FocusNode = FocusNode();
  FocusNode d10FocusNode = FocusNode();
  FocusNode d5FocusNode = FocusNode();
  FocusNode d2FocusNode = FocusNode();
  FocusNode d1FocusNode = FocusNode();

  @override
  void initState(){
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
  void dispose(){
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Denomination Count"),
        actions: [
          IconButton(
            onPressed: (){
              setState(() {
                _d200Controller.text = "";
                _d100Controller.text = "";
                _d50Controller.text = "";
                _d20Controller.text = "";
                _d10Controller.text = "";
                _d5Controller.text = "";
                _d2Controller.text = "";
                _d1Controller.text = "";
                d200 = 0;
                d100 = 0;
                d50 = 0;
                d20 = 0;
                d10 = 0;
                d5 = 0;
                d2 = 0;
                d1 = 0;
                total = 0;
              });

            },
            icon: const Icon(Icons.refresh),
          )
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
                                var dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d200 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = int.parse(value) * 200;
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
                                // var dt =
                                //     int.parse(value) * 100;
                                // setState(() {
                                //   d100 = dt;
                                // });

                                var dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d100 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = int.parse(value) * 100;
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

                                var dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d50 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = int.parse(value) * 50;
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
                                var dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d20 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = int.parse(value) * 20;
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
                                var dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d10 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = int.parse(value) * 10;
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

                                var dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d5 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = int.parse(value) * 5;
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
                                var dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d2 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = int.parse(value) * 2;
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
                                var dt = 0;
                                if(value.isEmpty){
                                  setState(() {
                                    dt = 0;
                                    d1 = 0;
                                  });
                                }
                                else{
                                  setState(() {
                                    dt = int.parse(value) * 1;
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

                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    var mainTotal = d200 + d100 + d50 + d20 + d10 + d5 + d2 + d1;
                        setState(() {
                            total = mainTotal;
                          });

                  },child: const Text("Calculate",style: TextStyle(color: defaultWhite,fontWeight: FontWeight.bold),),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child:Text("Total: ",style:TextStyle(fontWeight: FontWeight.bold,color:warning,fontSize: 20))
                    ),Center(
                      child:Text(total.toString(),style:const TextStyle(fontWeight: FontWeight.bold,color:warning,fontSize: 20))
                    ),
                  ],
                )
              ],
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
