
import 'dart:async';
import 'dart:convert';
import 'package:device_apps/device_apps.dart';
import 'package:easy_agent/controllers/customerscontroller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../controllers/profilecontroller.dart';
import '../../widgets/loadingui.dart';
import '../customers/customeraccounts.dart';
import '../customers/registercustomer.dart';
import '../dashboard.dart';
import '../sendsms.dart';

class BankDeposit extends StatefulWidget {
  const BankDeposit({Key? key}) : super(key: key);

  @override
  State<BankDeposit> createState() => _BankDepositState();
}

class _BankDepositState extends State<BankDeposit> {
  final CustomersController controller = Get.find();
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
  late List customersPhone = [];
  late List accountNames = [];


  Future<void> _launchInBrowser(String url) async {
    final appLink = Uri.parse(url);
    if (!await launchUrl(appLink)) {
      throw 'Could not launch $url';
    }
  }



  final List customerBanks = [
    "Select bank",
  ];
  final List customerAccounts = [
    "Select account number"
  ];
  var _currentAccountNumberSelected = "Select account number";

  final List customerAccountsNumbers = [];
  var _currentSelectedBank = "Select bank";
  var customerDetailBanks = {};

  late List deCustomer = [];
  bool isAccountNumberAndName = false;
  late String customerAccountName = "";
  bool isFetching = false;
  bool bankSelected = false;
  bool fetchingCustomerAccounts = true;
  late List customer = [];
  late List myUser = [];

  late final TextEditingController _amountController;
  late final TextEditingController _customerPhoneController;
  late final TextEditingController _depositorNameController;
  late final TextEditingController _depositorNumberController;
  late final TextEditingController _customerAccountNameController;
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
  bool amountNotEqualTotal = false;
  FocusNode amountFocusNode = FocusNode();
  FocusNode customerPhoneFocusNode = FocusNode();
  FocusNode depositorNameFocusNode = FocusNode();
  FocusNode depositorNumberFocusNode = FocusNode();
  FocusNode customerAccountNameFocusNode = FocusNode();
  FocusNode d200FocusNode = FocusNode();
  FocusNode d100FocusNode = FocusNode();
  FocusNode d50FocusNode = FocusNode();
  FocusNode d20FocusNode = FocusNode();
  FocusNode d10FocusNode = FocusNode();
  FocusNode d5FocusNode = FocusNode();
  FocusNode d2FocusNode = FocusNode();
  FocusNode d1FocusNode = FocusNode();
  bool isCustomer = false;
  bool isDirect = false;
  double totalNow = 0.0;
  bool amountIsNotEmpty = false;
  late String customerName = "";
  bool isLoading = true;
  bool accountNumberSelected = false;


  fetchCustomerAccounts() async {
    final agentUrl = "https://fnetagents.xyz/get_customer_account/${_customerPhoneController.text}/";
    final agentLink = Uri.parse(agentUrl);
    http.Response res = await http.get(agentLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      myUser = jsonData;
      for(var i in myUser){
        if (!customerBanks.contains(i['bank'])) {
          customerBanks.add(i['bank']);
        }
        if(i['customer'] != _customerPhoneController.text.trim()){
          Get.snackbar(
              "Customer Account Error", "Customer has no bank registered",
              colorText: defaultWhite,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 5),
              backgroundColor: warning);
          Timer(const Duration(seconds: 3),
                  () => Get.to(() => const CustomerAccountRegistration()));
        }
        else{
          Get.snackbar(
              "Customer Account Success", "Customer has banks registered",
              colorText: defaultWhite,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 5),
              backgroundColor: snackBackground);
        }
      }

      setState(() {
        fetchingCustomerAccounts = false;
      });
    }
  }

  fetchCustomerBankAndNames(String deBank)async{
    try{
      final customerAccountUrl = "https://fnetagents.xyz/get_customer_accounts_by_bank/${_customerPhoneController.text}/$deBank";
      final customerAccountLink = Uri.parse(customerAccountUrl);
      http.Response response = await http.get(customerAccountLink, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $uToken"
      });
      if(response.statusCode == 200){
        final results = response.body;
        var jsonData = jsonDecode(results);
        deCustomer = jsonData;

        for(var cm in deCustomer){
          if(!customerAccounts.contains(cm['account_number'])){
            customerAccounts.add(cm['account_number']);
            accountNames.add(cm['account_name']);
          }
        }
      }
      else{
        if (kDebugMode) {
          print(response.body);
        }
      }
    }
    finally{
      setState(() {
        isFetching = true;
      });
    }
  }

  fetchCustomer(String customerPhone)async{
    final url = "https://fnetagents.xyz/get_customer_by_phone/$customerPhone/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      customer = json.decode(jsonData);

      for (var i in customer) {
        setState(() {
          customerName = i['name'];
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }
  final SendSmsController sendSms = SendSmsController();


  late String uToken = "";
  final storage = GetStorage();
  Future<void> openFinancialServices() async {
    await UssdAdvanced.multisessionUssd(
        code: "*171*6*1*1#", subscriptionId: 1);
  }

  ProfileController profileController = Get.find();
  late List ownerDetails = [];
  late String ownerId = "";
  late String ownerUsername = "";

  Future<void> fetchOwnersDetails() async {
    final postUrl = "https://fnetagents.xyz/get_supervisor_with_code/${profileController.ownerCode}/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      ownerDetails.assignAll(allPosts);
      for(var i in ownerDetails){
        ownerId = i['id'].toString();
        ownerUsername = i['username'];
      }
      setState(() {
        isLoading = false;
      });
    } else {
      // print(res.body);
    }
  }

  processBankDeposit() async {
    const registerUrl = "https://fnetagents.xyz/post_bank_deposit/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "owner": ownerId,
      "agent": profileController.userId,
      "depositor_name": _depositorNameController.text.trim(),
      "depositor_number": _depositorNumberController.text.trim(),
      "bank": _currentSelectedBank,
      "account_number": _currentAccountNumberSelected,
      "account_name": _customerAccountNameController.text.trim(),
      "amount": _amountController.text.trim(),
      "customer": _customerPhoneController.text.trim(),
      "d_200": _d200Controller.text.trim(),
      "d_100": _d100Controller.text.trim(),
      "d_50": _d50Controller.text.trim(),
      "d_20": _d20Controller.text.trim(),
      "d_10": _d10Controller.text.trim(),
      "d_5": _d5Controller.text.trim(),
      "d_2": _d2Controller.text.trim(),
      "d_1": _d1Controller.text.trim(),
    });

    if (res.statusCode == 201) {
      String num = _customerPhoneController.text.replaceFirst("0", '+233');
      sendSms.sendMySms(num, "EasyAgent","Your deposit of ${_amountController.text.trim()} into your $_currentSelectedBank was successful.Thank you for working with Easy Agent.");
      Get.snackbar("Congratulations", "Transaction was successful",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: snackBackground,
          duration: const Duration(seconds: 5));
      Get.offAll(()=> const Dashboard());
      showInstalled();

    }
    else {
      Get.snackbar("Deposit Error", "something went wrong please try again",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
    }

  }

  void showInstalled() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Card(
        elevation: 12,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10))),
        child: SizedBox(
          height: 450,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                  child: Text("Continue with mtn's financial services",
                      style: TextStyle(
                          fontWeight: FontWeight.bold))),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      openFinancialServices();
                      // Get.back();
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/momo.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("MTN",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              const Center(
                  child: Text("Continue with app",
                      style: TextStyle(
                          fontWeight: FontWeight.bold))),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async{
                      await _launchInBrowser("https://xpresspoint.ecobank.com/agencybankingWEB/");
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/xpresspoint.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Express Point",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                     await _launchInBrowser("https://dpfbgl101.myfidelitybank.net:7101/solution.html");
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/fidelity-card.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Fidelity Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      await _launchInBrowser("https://ams.caleservice.net/");
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/calbank.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Cal Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              const Divider(),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('com.accessbank.accessbankapp');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/accessbank.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Access Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('com.m2i.gtexpressbyod');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/gtbank.jpg",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("GT Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  late List allFraudsters = [];
  bool isFraudster = false;

  Future<void> getAllFraudsters() async {
    try {
      const url = "https://fnetagents.xyz/get_all_fraudsters/";
      var link = Uri.parse(url);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $uToken"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allFraudsters.assignAll(jsonData);
      }
    } catch (e) {
      Get.snackbar("Sorry",
          "something happened or please check your internet connection");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> fetchAllInstalled() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true, includeSystemApps: false);
    if (kDebugMode) {
      print(apps);
    }
  }


  @override
  void initState(){
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    fetchOwnersDetails();
    fetchAllInstalled();
    _amountController = TextEditingController();
    _customerPhoneController = TextEditingController();
    _depositorNameController = TextEditingController();
    _depositorNumberController = TextEditingController();
    _customerAccountNameController = TextEditingController();
    _d200Controller = TextEditingController();
    _d100Controller = TextEditingController();
    _d50Controller = TextEditingController();
    _d20Controller = TextEditingController();
    _d10Controller = TextEditingController();
    _d5Controller = TextEditingController();
    _d2Controller = TextEditingController();
    _d1Controller = TextEditingController();
    controller.getAllCustomers(uToken);
    getAllFraudsters();
  }

  @override
  void dispose(){
    super.dispose();
    _amountController.dispose();
    _customerPhoneController.dispose();
    _depositorNameController.dispose();
    _depositorNumberController.dispose();
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
        title: const Text("Bank Deposit",style:TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: secondaryColor,
      ),
      body: isLoading ? const LoadingUi() : ListView(
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
                    child: TextFormField(
                      onChanged: (value) {
                        if(value.length == 10 && allFraudsters.contains(value)){
                          setState(() {
                            isFraudster = true;
                          });
                          Get.snackbar("Customer Error", "This customer is in the fraud lists.",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 10),
                              backgroundColor: warning);
                          return;
                        }
                        else{
                          setState(() {
                            isFraudster = false;
                          });
                        }
                        if (value.length == 10 &&
                            controller.customersNumbers.contains(value)) {
                          Get.snackbar("Success", "Customer is registered",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 5),
                              backgroundColor: snackBackground);
                          setState(() {
                            isCustomer = true;
                          });
                          fetchCustomerAccounts();
                          fetchCustomer(_customerPhoneController.text);

                        } else if (value.length == 10 &&
                            !controller.customersNumbers.contains(value)) {
                          Get.snackbar(
                              "Customer Error", "Customer is not registered",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: warning);
                          setState(() {
                            isCustomer = false;
                          });
                          Timer(const Duration(seconds: 3),
                                  () => Get.to(() => const CustomerRegistration()));
                        }
                      },
                      controller: _customerPhoneController,
                      focusNode: customerPhoneFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Customer's Number"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter customer's number";
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10,),

                  isCustomer && !fetchingCustomerAccounts ?
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select bank"),
                          isExpanded: true,
                          underline: const SizedBox(),
                          // style: const TextStyle(
                          //     color: Colors.black, fontSize: 20),
                          items: customerBanks.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            fetchCustomerBankAndNames(newValueSelected.toString());
                            _onDropDownItemSelectedBank(newValueSelected);
                          },
                          value: _currentSelectedBank,
                        ),
                      ),
                    ),
                  ): isCustomer ? const Text("Please wait fetching customer's banks"):Container(),
                  isCustomer && isFetching ? Column(
                    children: [
                      accountNumberSelected ? Container() :
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10),
                            child: DropdownButton(
                              hint: const Text("Select account number"),
                              isExpanded: true,
                              underline: const SizedBox(),
                              // style: const TextStyle(
                              //     color: Colors.black, fontSize: 20),
                              items: customerAccounts.map((dropDownStringItem) {
                                return DropdownMenuItem(
                                  value: dropDownStringItem,
                                  child: Text(dropDownStringItem),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                for(var cNum in myUser){
                                  if(cNum['account_number'] == newValueSelected){
                                    setState(() {
                                      isAccountNumberAndName = true;
                                      customerAccountName = cNum['account_name'];
                                      accountNumberSelected = true;
                                    });
                                  }
                                }
                                _onDropDownItemSelectedAccountNumber(newValueSelected);
                              },
                              value: _currentAccountNumberSelected,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ): bankSelected ? Text("Please wait fetching customer's $_currentSelectedBank account numbers"):Container(),

                  isAccountNumberAndName ?
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          readOnly: true,
                          initialValue: _currentAccountNumberSelected.toString(),
                          cursorColor: secondaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: buildInputDecoration("Account Number"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _customerAccountNameController..text=customerAccountName,
                          cursorColor: secondaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          readOnly: true,
                          decoration: buildInputDecoration("Account Name"),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter a name";
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(

                          controller: _depositorNameController,
                          cursorColor: secondaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: buildInputDecoration("Depositor Name"),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter depositor";
                            }
                          },
                        ),
                      ),
                    ],
                  ):
                  Container(),

                 isCustomer && isAccountNumberAndName ? Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length > 1 && value != ""){
                          setState(() {
                            amountIsNotEmpty = true;
                          });
                        }
                        if(value == ""){
                          setState(() {
                            amountIsNotEmpty = false;
                          });
                        }

                      },
                      controller: _amountController,
                      focusNode: amountFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Amount"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter amount";
                        }
                      },
                    ),
                  ) : Container(),
                  amountIsNotEmpty
                      ? Column(
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
                                      // var dt =
                                      //     int.parse(value) * 1;
                                      // setState(() {
                                      //   d1 = dt;
                                      // });
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
                      Row(
                        children: [
                          Expanded(
                              child: amountNotEqualTotal
                                  ? Text(
                                "TOTAL: $total",
                                style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 20),
                              )
                                  : const Text("")),
                          const SizedBox(
                            width: 10,
                          ),
                          const Expanded(child: Text(""))
                        ],
                      ),
                    ],
                  )
                      : Container(),
                  const SizedBox(height: 30,),
                  isPosting  ? const LoadingUi() :
                  isCustomer && !isFraudster ? NeoPopTiltedButton(
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
                        var mainTotal = d200 + d100 + d50 + d20 + d10 + d5 + d2 + d1;
                        if(int.parse(_amountController.text) != mainTotal){
                          Get.snackbar("Total Error", "Your total should be equal to the amount",
                              colorText: defaultWhite,
                              backgroundColor: warning,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 5)
                          );
                          setState(() {
                            total = mainTotal;
                            amountNotEqualTotal = true;
                          });
                          return;
                        }
                        else if(_currentSelectedBank == "Select Bank"){
                          Get.snackbar("Bank Error", "please select bank",
                              colorText: defaultWhite,
                              backgroundColor: warning,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 5));
                          return;
                        }
                        else{
                          processBankDeposit();
                        }
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
                  ) : Container(),
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
  void _onDropDownItemSelectedBank(newValueSelected) {
    setState(() {
      _currentSelectedBank = newValueSelected;
    });
  }

  void _onDropDownItemSelectedAccountNumber(newValueSelected) {
    setState(() {
      _currentAccountNumberSelected = newValueSelected;
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
}
