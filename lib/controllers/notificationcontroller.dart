import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController{
  List notifications = [];
  List notificationsUnread = [];
  bool isLoading = false;

  Future<void> getAllNotifications(String token) async {
    try{
      isLoading = true;
      const url = "https://fnetagents.xyz/get_my_notifications/";
      var myLink = Uri.parse(url);
      final response =
      await http.get(myLink, headers: {"Authorization": "Token $token"});
      if (response.statusCode == 200) {
        final codeUnits = response.body.codeUnits;
        var jsonData = const Utf8Decoder().convert(codeUnits);
        notifications = json.decode(jsonData);
        update();
      } else {
        if (kDebugMode) {
          // print(response.body);
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    finally {
      isLoading = false;
    }
  }
  Future<void> getAllUnReadNotifications(String token) async {
    try{
      isLoading = true;
      const url = "https://fnetagents.xyz/get_my_unread_notifications/";
      var myLink = Uri.parse(url);
      final response =
      await http.get(myLink, headers: {"Authorization": "Token $token"});
      if (response.statusCode == 200) {
        final codeUnits = response.body.codeUnits;
        var jsonData = const Utf8Decoder().convert(codeUnits);
        notificationsUnread = json.decode(jsonData);
        update();
      } else {
        if (kDebugMode) {
          // print(response.body);
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    finally {
      isLoading = false;
    }
  }
  Future<void> readNotifications(String token) async {
    try{
      isLoading = true;
      const url = "https://fnetagents.xyz/read_notification/";
      var myLink = Uri.parse(url);
      final response =
      await http.get(myLink, headers: {"Authorization": "Token $token"});
      if (response.statusCode == 200) {
        // final codeUnits = response.body.codeUnits;
        // var jsonData = const Utf8Decoder().convert(codeUnits);
        // notificationsUnread = json.decode(jsonData);
        update();
      } else {
        if (kDebugMode) {
          // print(response.body);
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    finally {
      isLoading = false;
    }
  }

}