import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CustomersController extends GetxController{
  late List allCustomers = [];
  late List allMyCustomers = [];
  late List customersNumbers = [];
  late List customersNames = [];
  bool isLoading = true;

  static CustomersController get to => Get.find<CustomersController>();


  Future<void> getAllCustomers(String token) async {
    try {
      isLoading = true;
      const completedRides = "https://fnetagents.xyz/get_all_customers/";
      var link = Uri.parse(completedRides);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allCustomers.assignAll(jsonData);
        for(var i in allCustomers){
          if(!customersNumbers.contains(i['phone'])){
            customersNumbers.add(i['phone']);
          }
          if(!customersNames.contains(i['name'])){
            customersNames.add(i['name']);
          }
        }
        update();
      }
    } catch (e) {
      Get.snackbar("Sorry","something happened or please check your internet connection");
    } finally {
      isLoading = false;
    }
  }

}