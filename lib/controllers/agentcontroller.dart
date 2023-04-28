import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AgentController extends GetxController{
  late List allAccounts = [];
  late List allMyRegisteredBanks = [];
  late List allMyRegisteredAccountNumbers = [];
  late List allMyRegisteredAccountNames = [];
  late List allMyRegisteredBranches = [];
  bool isLoading = true;


  Future<void> getAllMyAccounts(String token) async {
    try {
      isLoading = true;
      const completedRides = "https://fnetagents.xyz/get_my_accounts/";
      var link = Uri.parse(completedRides);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allAccounts.assignAll(jsonData);

        for(var i in allAccounts){
          if(!allMyRegisteredBanks.contains(i['bank'])){
            allMyRegisteredBanks.add(i['bank']);
          }
          if(!allMyRegisteredAccountNumbers.contains(i['account_number'])){
            allMyRegisteredAccountNumbers.add(i['account_number']);
          }
          if(!allMyRegisteredAccountNames.contains(i['account_name'])){
            allMyRegisteredAccountNames.add(i['account_name']);
          }
          if(!allMyRegisteredBranches.contains(i['branch'])){
            allMyRegisteredBranches.add(i['branch']);
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