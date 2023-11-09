import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/customers/searchcustomers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/customerscontroller.dart';
import 'mycustomersaccounts.dart';

class MyCustomers extends StatefulWidget {
  const MyCustomers({Key? key}) : super(key: key);

  @override
  State<MyCustomers> createState() => _MyCustomersState();
}

class _MyCustomersState extends State<MyCustomers> {
  final CustomersController controller = Get.find();
  late String uToken = "";
  final storage = GetStorage();
  var items;

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
        title: const Text("My Customers"),
      ),
      body: GetBuilder<CustomersController>(builder: (controller) {
        return ListView.builder(
            itemCount: controller.allMyCustomers != null
                ? controller.allMyCustomers.length
                : 0,
            itemBuilder: (context, index) {
              items = controller.allMyCustomers[index];
              return Card(
                color: secondaryColor,
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: () {
                    Get.to(() => MyCustomersAccounts(
                        phone_number: controller.allMyCustomers[index]
                            ['phone']));
                  },
                  title: buildRow("Name: ", "name"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildRow("Phone : ", "phone"),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 2),
                        child: Row(
                          children: [
                            const Text(
                              "Date: ",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              items['date_created'].toString().split("T").first,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 18.0, left: 8, bottom: 10),
                        child: Text("Tap to view accounts",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              );
            });
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: snackBackground,
        onPressed: () {
          Get.to(() => const SearchCustomers());
        },
        child: const Icon(
          Icons.search_rounded,
          size: 30,
          color: defaultWhite,
        ),
      ),
    );
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
