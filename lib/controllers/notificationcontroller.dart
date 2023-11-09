import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController {
  bool isLoading = true;
  late List yourNotifications = [];
  late List notRead = [];
  late List triggered = [];
  late List unreadNotifications = [];
  late List triggeredNotifications = [];
  late List allNotifications = [];
  late List allNots = [];

  Future<void> getAllTriggeredNotifications(String token) async {
    const url = "https://fnetagents.xyz/get_triggered_notifications/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $token"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      triggeredNotifications = json.decode(jsonData);
      triggered.assignAll(triggeredNotifications);
      update();
    } else {
      if (kDebugMode) {
        print(response.body);
      }
    }
  }

  Future<void> getAllUnReadNotifications(String token) async {
    const url = "https://fnetagents.xyz/get_my_unread_notifications/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $token"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      yourNotifications = json.decode(jsonData);
      notRead.assignAll(yourNotifications);
      update();
    } else {
      if (kDebugMode) {
        print(response.body);
      }
    }
  }

  Future<void> getAllNotifications(String token) async {
    const url = "https://fnetagents.xyz/get_my_notifications/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $token"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allNotifications = json.decode(jsonData);
      allNots.assignAll(allNotifications);
      // print(response.body);
      update();
    } else {
      if (kDebugMode) {
        print(response.body);
      }
    }
  }

  unTriggerNotifications(int id, String token) async {
    final requestUrl = "https://fnetagents.xyz/un_trigger_notification/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $token"
    }, body: {
      "notification_trigger": "Not Triggered",
      "read": "Read",
    });
    if (response.statusCode == 200) {}
  }

  Future<void> updateReadNotification(String token) async {
    const requestUrl = "https://fnetagents.xyz/read_notification/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $token"
    }, body: {});
    if (response.statusCode == 200) {
    } else {
      if (kDebugMode) {
        print(response.body);
      }
    }
  }
}
