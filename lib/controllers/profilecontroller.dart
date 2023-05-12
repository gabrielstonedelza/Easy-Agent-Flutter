import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ProfileController extends GetxController{
  static ProfileController get to => Get.find<ProfileController>();
  bool isLoading = false;
  List profileDetails = [];
  late String userId = "";
  late String agentPhone = "";
  late String supervisorCode = "";

  Future<void> getUserProfile(String token) async {
    try {
      isLoading = true;

      const profileLink = "https://fnetagents.xyz/get_agents_profile/";
      var link = Uri.parse(profileLink);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        profileDetails = jsonData;
        update();
      }
      else{
        if (kDebugMode) {
          print(response.body);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getUserDetails(String token) async {
    try {
      isLoading = true;

      const profileLink = "https://fnetagents.xyz/get_user_details/";
      var link = Uri.parse(profileLink);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        profileDetails = jsonData;
        for(var i in profileDetails){
          userId = i['id'].toString();
          agentPhone = i['phone_number'];
          supervisorCode = i['supervisor'];
        }
        update();
      }
      else{
        if (kDebugMode) {
          print(response.body);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      isLoading = false;
      update();
    }
  }
}