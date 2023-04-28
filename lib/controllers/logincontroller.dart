import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../screens/authenticatebyphone.dart';
import '../screens/preregistersuccess.dart';

class LoginController extends GetxController {
  final client = http.Client();
  final storage = GetStorage();
  bool isLoggingIn = false;
  bool isUser = false;
  late List allAgents = [];
  late List agentsCodes = [];
  late List agentsEmails = [];
  late int oTP = 0;
  late String myToken = "";

  String errorMessage = "";
  bool isLoading = false;



  Future<void> getAllAgents() async {
    try {
      isLoading = true;
      const completedRides = "https://fnetagents.xyz/get_all_agents/";
      var link = Uri.parse(completedRides);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allAgents.assignAll(jsonData);
        for (var i in allAgents) {
          agentsCodes.add(i['agent_unique_code']);
        }
        update();

      }
    } catch (e) {
      Get.snackbar("Sorry",
          "something happened or please check your internet connection");
    } finally {
      isLoading = false;
    }
  }

  Future<void> loginUser(String agentCode, String password) async {
    const loginUrl = "https://fnetagents.xyz/auth/token/login/";
    final myLink = Uri.parse(loginUrl);
    http.Response response = await client.post(myLink,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"agent_unique_code": agentCode, "password": password});

    if (response.statusCode == 200) {
      final resBody = response.body;
      var jsonData = jsonDecode(resBody);
      var userToken = jsonData['auth_token'];

      storage.write("token", userToken);
      storage.write("agent_code", agentCode);
      isLoggingIn = false;
      isUser = true;

      if (agentsCodes.contains(agentCode)) {
        Get.offAll(() => const AuthenticateByPhone());
      } else {
        Get.snackbar(
            "Sorry 😢", "You are not an agent or you entered invalid details",
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        isLoggingIn = false;
        isUser = false;
      }
    } else {
      Get.snackbar("Sorry 😢", "invalid details",
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      isLoggingIn = false;
      isUser = false;
    }
  }

  addAgentPreRegistration(
      String name, String phoneNum, String digitAddress) async {
    const requestUrl = "https://fnetagents.xyz/add_agent_pre_reg/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    }, body: {
      "name": name,
      "phone_number": phoneNum,
      "digital_address": digitAddress,
    });
    if (response.statusCode == 201) {
      Get.snackbar("Hurray 😀", "Details sent successfully,we will contact you soon",
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: secondaryColor,
          duration: const Duration(seconds: 5));
      Get.offAll(() => const RegisterSuccess());
      update();
    } else {
      Get.snackbar(
        "Agent Error",
        "Agent with same details already exists or check your internet connection",
        duration: const Duration(seconds: 5),
        colorText: Colors.white,
        backgroundColor: warning,
      );
    }
  }

  resetPassword(String email) async {
    const requestUrl = "https://fnetagents.xyz/add_agent_pre_reg/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    }, body: {
      "email": email,
    });
    if (response.statusCode == 201) {
      Get.snackbar("Hurray 😀", "Please check your email and reset your password",
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 5));
      Get.offAll(() => const RegisterSuccess());
      update();
    } else {
      Get.snackbar(
        "Agent Error",
        "Email does not exists or check your internet connection",
        duration: const Duration(seconds: 5),
        colorText: Colors.white,
        backgroundColor: primaryColor,
      );
    }
  }
}
