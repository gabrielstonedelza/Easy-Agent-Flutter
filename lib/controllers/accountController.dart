import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AccountController extends GetxController {
  late List allAccounts = [];
  late List allMyRegisteredBanks = [];
  late List allMyRegisteredAccountNumbers = [];
  late List allMyRegisteredAccountNames = [];
  late List allMyRegisteredBranches = [];
  bool isLoading = true;
  late List accountBalanceDetailsClosedToday = [];
  bool hasClosedAccountToday = false;
  DateTime now = DateTime.now();
  late List allRequests = [];
  bool hasSomePendings = false;
  late List allPendingList = [];
  late List allFraudsters = [];
  late List ownerDetails = [];
  late String ownerId = "";
  late String ownerUsername = "";
  late String userEmail = "";
  late String agentUsername = "";
  late String companyName = "";
  late String userId = "";
  late String agentPhone = "";
  List profileDetails = [];
  late List allPayToForAgent = [];
  late List date_added_for_agent = [];
  late List date_added_for_merchant = [];
  late List allMomoDeposits = [];
  late List mtnDepositDates = [];
  late List allMomoWithdrawals = [];
  late List mtnWithdrawalsDates = [];
  late List allBankDeposits = [];
  late List bankDepositDates = [];
  late List allBankWithdrawals = [];
  late List bankWithdrawalDates = [];

  late List allMyReports = [];
  late String agentUniqueCode = "";
  late List accountBalanceDetailsToday = [];
  late List lastItem = [];
  late double physical = 0.0;
  late double mtn = 0.0;
  late double airteltigo = 0.0;
  late double vodafone = 0.0;
  late double eCash = 0.0;
  late double mtnNow = 0.0;
  late double airtelTigoNow = 0.0;
  late double vodafoneNow = 0.0;
  late double physicalNow = 0.0;
  late double eCashNow = 0.0;
  late List allMyAccounts = [];

  Future<void> fetchAccountBalance(String token) async {
    try {
      isLoading = true;
      const postUrl =
          "https://fnetagents.xyz/get_my_account_balance_started_today/";
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
        lastItem.assign(accountBalanceDetailsToday.last);
        physicalNow = double.parse(lastItem[0]['physical']);
        mtnNow = double.parse(lastItem[0]['mtn_e_cash']);
        airtelTigoNow = double.parse(lastItem[0]['tigo_airtel_e_cash']);
        vodafoneNow = double.parse(lastItem[0]['vodafone_e_cash']);
        eCashNow = double.parse(lastItem[0]['mtn_e_cash']) +
            double.parse(lastItem[0]['tigo_airtel_e_cash']) +
            double.parse(lastItem[0]['vodafone_e_cash']);
        update();
      } else {
        // print(res.body);
      }
    } catch (e) {
    } finally {
      isLoading = false;
    }
  }

  Future<void> getAllMyReports(String token) async {
    try {
      const url = "https://fnetagents.xyz/get_my_reports/";
      var link = Uri.parse(url);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allMyReports.assignAll(jsonData);
      }
    } catch (e) {
      // Get.snackbar("Sorry",
      //     "something happened or please check your internet connection");
    } finally {
      isLoading = false;
    }
  }

  Future<void> deleteReport(String id) async {
    final url = "https://fnetagents.xyz/delete_report/$id";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 204) {
      // Get.offAll(() => const Dashboard());
    } else {}
  }

  Future<void> fetchAllBankWithdrawals(String token) async {
    try {
      isLoading = true;
      const url = "https://fnetagents.xyz/get_my_bank_withdrawals/";
      var myLink = Uri.parse(url);
      final response =
          await http.get(myLink, headers: {"Authorization": "Token $token"});

      if (response.statusCode == 200) {
        final codeUnits = response.body.codeUnits;
        var jsonData = const Utf8Decoder().convert(codeUnits);
        allBankWithdrawals = json.decode(jsonData);

        for (var i in allBankWithdrawals) {
          if (!bankWithdrawalDates
              .contains(i['date_of_withdrawal'].toString().split("T").first)) {
            bankWithdrawalDates
                .add(i['date_of_withdrawal'].toString().split("T").first);
          }
        }
      }
    } catch (e) {
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchAllBankDeposits(String token) async {
    try {
      const url = "https://fnetagents.xyz/get_my_bank_deposits/";
      var myLink = Uri.parse(url);
      final response =
          await http.get(myLink, headers: {"Authorization": "Token $token"});

      if (response.statusCode == 200) {
        final codeUnits = response.body.codeUnits;
        var jsonData = const Utf8Decoder().convert(codeUnits);
        allBankDeposits = json.decode(jsonData);

        for (var i in allBankDeposits) {
          if (!bankDepositDates
              .contains(i['date_added'].toString().split("T").first)) {
            bankDepositDates.add(i['date_added'].toString().split("T").first);
          }
        }
      }
    } catch (e) {
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchAllMtnWithdrawals(String token) async {
    try {
      isLoading = true;
      const url = "https://fnetagents.xyz/get_my_momo_withdraws/";
      var myLink = Uri.parse(url);
      final response =
          await http.get(myLink, headers: {"Authorization": "Token $token"});

      if (response.statusCode == 200) {
        final codeUnits = response.body.codeUnits;
        var jsonData = const Utf8Decoder().convert(codeUnits);
        allMomoWithdrawals = json.decode(jsonData);
        for (var i in allMomoWithdrawals) {
          if (!mtnWithdrawalsDates
              .contains(i['date_of_withdrawal'].toString().split("T").first)) {
            mtnWithdrawalsDates
                .add(i['date_of_withdrawal'].toString().split("T").first);
          }
        }
      }
    } catch (e) {
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchAllMtnDeposits(String token) async {
    try {
      isLoading = true;
      const url = "https://fnetagents.xyz/get_my_momo_deposits/";
      var myLink = Uri.parse(url);
      final response =
          await http.get(myLink, headers: {"Authorization": "Token $token"});

      if (response.statusCode == 200) {
        final codeUnits = response.body.codeUnits;
        var jsonData = const Utf8Decoder().convert(codeUnits);
        allMomoDeposits = json.decode(jsonData);
        for (var i in allMomoDeposits) {
          if (!mtnDepositDates
              .contains(i['date_deposited'].toString().split("T").first)) {
            mtnDepositDates
                .add(i['date_deposited'].toString().split("T").first);
          }
        }
      }
    } catch (e) {
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchAllPayTo(String token) async {
    try {
      isLoading = true;
      const url = "https://fnetagents.xyz/get_all_my_pay_to/";
      var myLink = Uri.parse(url);
      final response =
          await http.get(myLink, headers: {"Authorization": "Token $token"});

      if (response.statusCode == 200) {
        final codeUnits = response.body.codeUnits;
        var jsonData = const Utf8Decoder().convert(codeUnits);
        allPayToForAgent = json.decode(jsonData);

        for (var i in allPayToForAgent) {
          if (i['pay_to_type'] == "Agent") {
            if (!date_added_for_agent
                .contains(i['date_added'].toString().split("T").first)) {
              date_added_for_agent
                  .add(i['date_added'].toString().split("T").first);
            }
          }
          if (i['pay_to_type'] == "Merchant") {
            if (!date_added_for_merchant
                .contains(i['date_added'].toString().split("T").first)) {
              date_added_for_merchant
                  .add(i['date_added'].toString().split("T").first);
            }
          }
        }
      }
    } catch (e) {
    } finally {
      isLoading = false;
    }
  }

  Future<void> getAllMyAccounts(String token) async {
    try {
      isLoading = true;
      const completedRides = "https://fnetagents.xyz/get_agent_accounts/";
      var link = Uri.parse(completedRides);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allAccounts.assignAll(jsonData);

        for (var i in allAccounts) {
          if (!allMyRegisteredBanks.contains(i['bank'])) {
            allMyRegisteredBanks.add(i['bank']);
          }
          if (!allMyRegisteredAccountNumbers.contains(i['account_number'])) {
            allMyRegisteredAccountNumbers.add(i['account_number']);
          }
          if (!allMyRegisteredAccountNames.contains(i['account_name'])) {
            allMyRegisteredAccountNames.add(i['account_name']);
          }
          if (!allMyRegisteredBranches.contains(i['branch'])) {
            allMyRegisteredBranches.add(i['branch']);
          }
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

  Future<void> getAllAgentsAccounts(String token) async {
    try {
      const url = "https://fnetagents.xyz/get_agent_accounts/";
      var link = Uri.parse(url);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allMyAccounts.assignAll(jsonData);
      }
    } catch (e) {
      // Get.snackbar("Sorry",
      //     "something happened or please check your internet connection");
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchAccountBalanceClosed(String token) async {
    try {
      isLoading = true;
      const postUrl =
          "https://fnetagents.xyz/get_my_account_balance_closed_today/";
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
        accountBalanceDetailsClosedToday.assignAll(allPosts);
        for (var i in accountBalanceDetailsClosedToday) {
          if (i['date_closed'] == now.toString().split(" ").first &&
              i['isClosed'] == true) {
            hasClosedAccountToday = true;
          }
        }
      } else {
        // print(res.body);
      }
    } catch (e) {
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchAllRequests(String token) async {
    try {
      isLoading = true;
      const url = "https://fnetagents.xyz/get_all_my_requests/";
      var myLink = Uri.parse(url);
      final response =
          await http.get(myLink, headers: {"Authorization": "Token $token"});

      if (response.statusCode == 200) {
        final codeUnits = response.body.codeUnits;
        var jsonData = const Utf8Decoder().convert(codeUnits);
        allRequests = json.decode(jsonData);
        for (var i in allRequests) {
          allPendingList.add(i['request_approved']);
          allPendingList.add(i['request_paid']);
          allPendingList.add(i['payment_approved']);
        }
      }
      if (allPendingList.contains("Pending")) {
        hasSomePendings = true;
        update();
      } else {
        hasSomePendings = false;
        update();
      }
    } catch (e) {
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getAllFraudsters(String token) async {
    try {
      const url = "https://fnetagents.xyz/get_all_fraudsters/";
      var link = Uri.parse(url);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allFraudsters.assignAll(jsonData);
      }
    } catch (e) {
      // Get.snackbar("Sorry",
      //     "something happened or please check your internet connection");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchOwnersDetails(String token, String ownerCode) async {
    try {
      isLoading = true;
      final postUrl =
          "https://fnetagents.xyz/get_supervisor_with_code/$ownerCode/";
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
        ownerDetails.assignAll(allPosts);
        for (var i in ownerDetails) {
          ownerId = i['id'].toString();
          ownerUsername = i['username'];
        }
      } else {
        // print(res.body);
      }
    } catch (e) {
    } finally {
      isLoading = false;
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
        for (var i in profileDetails) {
          userId = i['id'].toString();
          agentPhone = i['phone_number'];
          userEmail = i['email'];
          companyName = i['company_name'];
          agentUniqueCode = i['agent_unique_code'];
        }
      } else {
        if (kDebugMode) {
          print(response.body);
        }
      }
    } catch (e) {
    } finally {
      isLoading = false;
    }
  }
}
