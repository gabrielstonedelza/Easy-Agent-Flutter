import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class AuthPhoneController extends GetxController {
  late List authPhoneDetails = [];
  late String phoneModel = "";
  late String phoneId = "";
  late String phoneBrand = "";
  late String phoneFingerprint = "";
  bool isLoading = false;
  bool isAuthenticated = false;
  final storage = GetStorage();

  Future<void> fetchDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    phoneModel = androidInfo.model;
    phoneId = androidInfo.id;
    phoneBrand = androidInfo.brand;
    phoneFingerprint = androidInfo.fingerprint;
  }

  Future<void> fetchAuthPhone(String token) async {
    try {
      const postUrl = "https://fnetagents.xyz/get_my_phones_auth_details/";
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
        authPhoneDetails.assignAll(allPosts);
        for(var i in authPhoneDetails){
          if(i['phones_id'] == phoneId && i['phone_model'] == phoneModel && i['phone_brand'] && i['finger_print'] == phoneFingerprint && i['authenticated_phone'] == "True"){
            isAuthenticated = true;
          }
          else{
            isAuthenticated = false;
          }
        }
        update();
      } else {
        // print(res.body);
      }
    } catch (e) {
      // Get.snackbar("Sorry", "please check your internet connection");
    } finally {
      isLoading = false;
      update();
    }
  }

  authenticatePhone(String token,String pId,String pModel,String pBrand,String pFinPrint)async{
    const requestUrl = "https://fnetagents.xyz/authenticate_agent_phone/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $token"
    }, body: {
      "phone_id": pId,
      "phone_model": pModel,
      "phone_brand": pBrand,
      "finger_print": pFinPrint,
      "authenticated_phone": "True",
    });
    if (response.statusCode == 201) {
      Get.snackbar("Hurray 😀", "Your phone was authenticated",
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: secondaryColor,
          duration: const Duration(seconds: 5));
      update();
    }
    else{
      if (kDebugMode) {
        print(response.body);
      }
      // Get.snackbar("Authentication Error", "Your phone could not be authenticated. Please try again",
      //   duration: const Duration(seconds:5),
      //   colorText: Colors.white,
      //   backgroundColor: secondaryColor,
      // );
    }
  }
}
