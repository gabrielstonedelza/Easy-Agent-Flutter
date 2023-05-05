import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class TrialAndMonthlyPaymentController extends GetxController {
  late List myFreeTrialStatus = [];
  late List myMonthlyPaymentStatus = [];
  late List accountBalanceDetailsToday = [];
  bool isLoading = false;
  bool isAuthenticated = false;
  bool freeTrialEnded = false;
  bool monthEnded = false;
  final storage = GetStorage();
  late String endingDate = "";

  Future<void> fetchAccountBalance(String token) async {
    const postUrl = "https://fnetagents.xyz/get_my_account_balance_started_today/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $token"
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      accountBalanceDetailsToday.assignAll(allPosts);
    } else {
      // print(res.body);
    }
  }


  Future<void> fetchFreeTrial(String token) async {
    const postUrl = "https://fnetagents.xyz/get_my_free_trial/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $token"
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      myFreeTrialStatus.assignAll(allPosts);
      for(var i in myFreeTrialStatus){
        freeTrialEnded = i['trial_ended'];
        endingDate = i['end_date'];
      }
    } else {
      // print(res.body);
    }
  }

  Future<void> fetchMonthlyPayment(String token) async {
    const postUrl = "https://fnetagents.xyz/get_my_monthly_payment_status/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $token"
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      myMonthlyPaymentStatus.assignAll(allPosts);
      for(var i in myMonthlyPaymentStatus){
        monthEnded = i['month_ended'];
      }
    } else {
      // print(res.body);
    }

  }

  startFreeTrial(String token)async{
    const requestUrl = "https://fnetagents.xyz/start_free_trial/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $token"
    }, body: {
      "trial_started" : "True"

    });
    if (response.statusCode == 201) {
      storage.write("freeTrialStarted", "Started");
      Get.snackbar("Hurray 😀", "you have started your free trial",
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: secondaryColor,
          duration: const Duration(seconds: 5));
      update();
    }
    else{
      // Get.snackbar("Authentication Error", "something went wrong. Please try again",
      //   duration: const Duration(seconds:5),
      //   colorText: Colors.white,
      //   backgroundColor: secondaryColor,
      // );
    }
  }
}
