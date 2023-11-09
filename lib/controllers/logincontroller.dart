import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../screens/authenticatebyphone.dart';
import '../screens/login.dart';

class LoginController extends GetxController {
  final client = http.Client();
  final storage = GetStorage();
  bool isLoggingIn = false;
  bool isUser = false;
  late List allAgents = [];
  late List agentsCodes = [];
  late List agentsUsernames = [];
  late int oTP = 0;
  late String myToken = "";
  bool hasErrors = false;

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
          agentsUsernames.add(i['username']);
        }
        update();
      }
    } catch (e) {
      // Get.snackbar("Sorry",
      //     "something happened or please check your internet connection");
    } finally {
      isLoading = false;
    }
  }

  loginUser(String username, String password) async {
    const loginUrl = "https://fnetagents.xyz/auth/token/login/";
    final myLink = Uri.parse(loginUrl);
    http.Response response = await client.post(myLink,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"username": username, "password": password});

    if (response.statusCode == 200) {
      final resBody = response.body;
      var jsonData = jsonDecode(resBody);
      var userToken = jsonData['auth_token'];

      storage.write("token", userToken);
      storage.write("agent_code", username);
      storage.write("agent_username", username);
      isLoggingIn = false;
      isUser = true;

      if (agentsUsernames.contains(username)) {
        hasErrors = false;
        Get.offAll(() => const AuthenticateByPhone());
      } else {
        Get.snackbar(
            "Sorry 😢", "You are not an agent or you entered invalid details",
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        isLoggingIn = false;
        hasErrors = true;
        isUser = false;
        storage.remove("token");
        storage.remove("agent_code");
      }
    } else {
      Get.snackbar("Sorry 😢", "invalid details",
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      hasErrors = true;
      isLoggingIn = false;
      isUser = false;
      storage.remove("token");
      storage.remove("agent_code");
    }
  }

  logoutUser(String token) async {
    storage.remove("token");
    storage.remove("agent_code");
    storage.remove("phoneAuthenticated");
    storage.remove("IsAuthDevice");
    storage.remove("AppVersion");
    Get.offAll(() => const LoginView());
    const logoutUrl = "https://www.fnetagents.xyz/auth/token/logout";
    final myLink = Uri.parse(logoutUrl);
    http.Response response = await http.post(myLink, headers: {
      'Accept': 'application/json',
      "Authorization": "Token $token"
    });

    if (response.statusCode == 200) {
      Get.snackbar("Success", "You were logged out",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);
      storage.remove("token");
      storage.remove("agent_code");
      storage.remove("AppVersion");
      Get.offAll(() => const LoginView());
    }
  }
}
