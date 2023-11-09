import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/accountController.dart';
import '../../controllers/customerscontroller.dart';

class AgentAccounts extends StatefulWidget {
  const AgentAccounts({Key? key}) : super(key: key);

  @override
  State<AgentAccounts> createState() => _AgentAccountsState();
}

class _AgentAccountsState extends State<AgentAccounts> {
  final CustomersController controller = Get.find();
  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Accounts"),
        ),
        body: GetBuilder<AccountController>(builder: (controller) {
          return ListView.builder(
              itemCount: controller.allMyAccounts != null
                  ? controller.allMyAccounts.length
                  : 0,
              itemBuilder: (context, index) {
                items = controller.allMyAccounts[index];
                return Card(
                  color: secondaryColor,
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: buildRow("Bank: ", "bank"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildRow("Account No : ", "account_number"),
                        buildRow("Account Name : ", "account_name"),
                        buildRow("Branch : ", "branch"),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 2),
                          child: Row(
                            children: [
                              const Text(
                                "Date added: ",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                items['date_added'].toString().split("T").first,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        }));
  }

  Padding buildRow(String mainTitle, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            mainTitle,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            items[subtitle],
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
