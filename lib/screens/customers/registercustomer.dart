
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinput/pinput.dart';
import 'dart:io';
import '../../controllers/customerscontroller.dart';
import '../../widgets/loadingui.dart';
import '../sendsms.dart';

class CustomerRegistration extends StatefulWidget {
  const CustomerRegistration({Key? key}) : super(key: key);

  @override
  State<CustomerRegistration> createState() => _CustomerRegistrationState();
}

class _CustomerRegistrationState extends State<CustomerRegistration> {
  final _formKey = GlobalKey<FormState>();
  // final CustomersController controller = Get.find();
  final controller = CustomersController.to;

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
  late List allCustomers = [];
  bool isLoading = true;
  bool isInSystem = false;


  late String uToken = "";
  final storage = GetStorage();
  late String username = "";


  late final TextEditingController name;
  late final TextEditingController phoneController;

  late TextEditingController dob = TextEditingController();
  final SendSmsController sendSms = SendSmsController();
  FocusNode nameFocusNode = FocusNode();
  bool hasVerified = false;

  FocusNode phoneControllerFocusNode = FocusNode();
  String getRandom(int length){
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random r = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  late String customerCode = "";
  bool canTakeCustomersPicture = false;
  final List pictureOptions = [
    "Please select Yes Or No for picture",
    "Yes",
    "No"
  ];
  var _currentSelectedPictureOption = "Please select Yes Or No for picture";
  late int oTP = 0;

  @override
  void initState(){
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    generate5digit();
    name = TextEditingController();

    phoneController = TextEditingController();
    controller.getAllCustomers(uToken);

    setState(() {
      customerCode = getRandom(15);
    });
  }

  @override
  void dispose(){
    super.dispose();
    name.dispose();
    phoneController.dispose();
  }
  bool hasOTP = false;
  bool sentOTP = false;
  generate5digit() {
    var rng = Random();
    var rand = rng.nextInt(9000) + 1000;
    oTP = rand.toInt();
  }


  registerCustomer()async{
    const registerUrl = "https://fnetagents.xyz/register_customer/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "name": name.text,
      "phone": phoneController.text,
      "unique_code": customerCode,
    });
    if(res.statusCode == 201){
      Get.snackbar("Congratulations", "Customer was created successfully",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);
      String telnum = phoneController.text;
      telnum = telnum.replaceFirst("0", '+233');
      sendSms.sendMySms(telnum,"EasyAgent",
          "Welcome ${name.text}, you are now registered on Easy Agent App.Your unique code for transactions is ($customerCode),please do not share this code with anyone,store it somewhere on your phone and delete this messages.For more information please kindly call 0550222888.");
      Get.offAll(()=>const Dashboard());
    }
    else{
      Get.snackbar("Error", "Something went wrong",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red);
    }
  }

  File? image;
  var dio = Dio();
  bool isUpdating = false;
  bool hasImageData = false;

  Future _getFromGallery()async{
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1080,
        maxWidth: 1080
    );
    // PickedFile? pickedFile = await ImagePicker().getImage(
    //     source: ImageSource.gallery,
    //     maxHeight: 1080,
    //     maxWidth: 1080
    // );
    _cropImage(image!.path);
  }

  Future _getFromCamera()async{
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 1080,
        maxWidth: 1080
    );
    _cropImage(image!.path);
  }


  Future _cropImage(filePath)async{

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    if(croppedFile != null){
      final File imageFile = File(croppedFile.path);
      image = imageFile;
      setState(() {
        hasImageData = true;
      });
    }
    else{
      setState(() {
        hasImageData = false;
      });
    }
  }

  void _registerCustomerWithPicture(File file) async {
    try {
      //updating user profile details
      String fileName = file.path.split('/').last;
      var formData1 = FormData.fromMap({
        "name": name.text.trim(),
        "phone": phoneController.text.trim(),
        "unique_code": customerCode,
        'customer_pic': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      var response = await dio.post(
        'https://fnetagents.xyz/register_customer/',
        data: formData1,
        options: Options(headers: {
          "Authorization": "Token $uToken",
          "HttpHeaders.acceptHeader": "accept: application/json",
        }, contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 201) {
        Get.snackbar("Congratulations", "Customer was created successfully",
            colorText: defaultWhite,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 5),
            backgroundColor: snackBackground);
        String telnum = phoneController.text;
        telnum = telnum.replaceFirst("0", '+233');
        sendSms.sendMySms(telnum,"EasyAgent",
            "Welcome ${name.text}, you are now registered on Easy Agent App.For more information please kindly call 0550222888.");
        Get.offAll(() => const Dashboard());
      }
      else{
        if (kDebugMode) {
          print(response.data);
        }
        Get.snackbar("Sorry", "something happened",
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red);
      }
    } on DioError {
      Get.snackbar("Sorry", "something happened",
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new customer"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length == 10 && controller.customersNumbers.contains(value)){
                          Get.snackbar("Sorry", "Customer is already in the system",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: snackBackground);
                          setState(() {
                            isInSystem = true;
                          });
                        }
                        else if(value.length == 10 && !controller.customersNumbers.contains(value)){
                          Get.snackbar("New Customer", "Customer is not in the system",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: warning);
                          setState(() {
                            isInSystem = false;
                          });
                        }
                      },
                      controller: phoneController,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Phone"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter customer phone number";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: name,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Name"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter customer's name";
                        }
                        return null;
                      },
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
                          hint: const Text("Please select Yes Or No for picture"),
                          isExpanded: true,
                          underline: const SizedBox(),
                          // style: const TextStyle(
                          //     color: Colors.black, fontSize: 20),
                          items: pictureOptions.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            if(newValueSelected == "Yes"){
                              setState(() {
                                canTakeCustomersPicture = true;
                                hasVerified = true;
                                sentOTP = true;
                                String num = phoneController.text
                                    .replaceFirst("0", '+233');
                                sendSms.sendMySms(
                                    num, "EasyAgent", "Your code $oTP");
                              });
                            }
                            else{
                              setState(() {
                                canTakeCustomersPicture = false;
                                hasVerified = false;
                              });
                            }
                            _onDropDownItemSelectedPictureOption(newValueSelected);
                          },
                          value: _currentSelectedPictureOption,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  sentOTP && !hasOTP
                      ? const Text(
                    "An OTP was sent to the customers phone,enter it here",
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  )
                      : Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  sentOTP && !hasOTP
                      ? Pinput(
                    // defaultPinTheme: defaultPinTheme,
                    androidSmsAutofillMethod:
                    AndroidSmsAutofillMethod.smsRetrieverApi,
                    validator: (pin) {
                      if (pin?.length == 4 &&
                          pin == oTP.toString()) {
                        setState(() {
                          hasOTP = true;
                        });
                      } else {
                        setState(() {
                          hasOTP = false;
                        });
                        Get.snackbar("Code Error",
                            "you entered an invalid code",
                            colorText: defaultWhite,
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: warning,
                            duration: const Duration(seconds: 5));
                      }
                      return null;
                    },
                  )
                      : Container(),
                  canTakeCustomersPicture ? Column(
                    children: [
                      !hasImageData  ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Take customer's picture"),
                          IconButton(
                            onPressed: (){
                              Get.defaultDialog(
                                  buttonColor: primaryColor,
                                  title: "Select",
                                  content: Row(
                                    children: [
                                      Expanded(
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                child: const Icon(Icons.image,size: 30,),
                                                onTap: () {
                                                  _getFromGallery();
                                                  Get.back();
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                "Gallery",
                                                style: TextStyle(
                                                    // color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              )
                                            ],
                                          )),
                                      Expanded(
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                child: const Icon(Icons.camera_alt,size: 30,),
                                                onTap: () {
                                                  _getFromCamera();
                                                  Get.back();
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                "Camera",
                                                style: TextStyle(
                                                    // color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              )
                                            ],
                                          )),
                                    ],
                                  )
                              );
                            },
                            icon: const Icon(Icons.camera_alt_outlined,size: 30,),
                          )
                        ],
                      ) :
                      Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: Image.file(image!),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ) : Container(),
                  !isInSystem ? isPosting  ? const LoadingUi() : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RawMaterialButton(
                      fillColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      onPressed: (){
                        _startPosting();
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        if (!_formKey.currentState!.validate()) {
                          return;
                        } else {
                          if(image == null && _currentSelectedPictureOption == "Yes"){
                            Get.snackbar("Customer picture Error", "please upload customers picture",
                                colorText: defaultWhite,
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red);
                            return;
                          }
                          if(_currentSelectedPictureOption == "Please select Yes Or No for picture"){
                            Get.snackbar("Customer picture Error", "please upload yes or no",
                                colorText: defaultWhite,
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red);
                            return;
                          }
                          canTakeCustomersPicture ?
                          _registerCustomerWithPicture(image!) : registerCustomer();
                        }
                      },child: const Text("Save",style: TextStyle(color: defaultWhite,fontWeight: FontWeight.bold),),
                    ),
                  ) :Container(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onDropDownItemSelectedPictureOption(newValueSelected) {
    setState(() {
      _currentSelectedPictureOption = newValueSelected;
    });
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

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: secondaryColor),
      borderRadius: BorderRadius.circular(20),
    ),
  );
}