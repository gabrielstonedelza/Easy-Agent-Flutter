import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/accountController.dart';
import '../../controllers/customerscontroller.dart';

class MyReports extends StatefulWidget {
  const MyReports({Key? key}) : super(key: key);

  @override
  State<MyReports> createState() => _MyReportsState();
}

class _MyReportsState extends State<MyReports> {
  final CustomersController controller = Get.find();
  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;

  bool isPosting = false;

  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

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
          title: const Text("My Reports"),
        ),
        body: GetBuilder<AccountController>(builder: (controller) {
          return ListView.builder(
              itemCount: controller.allMyReports != null
                  ? controller.allMyReports.length
                  : 0,
              itemBuilder: (context, index) {
                items = controller.allMyReports[index];
                return Card(
                  color: secondaryColor,
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: buildRow("Date: ", "date_reported"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 8),
                          child: Text(
                            "Report : ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: defaultWhite),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 8, bottom: 8),
                          child: Text(items['report'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: defaultWhite)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 8, bottom: 8),
                          child: Row(
                            children: [
                              const Text("Time: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: defaultWhite)),
                              Text(
                                  items['time_reported']
                                      .toString()
                                      .split(".")
                                      .first,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: defaultWhite)),
                            ],
                          ),
                        )
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
          Expanded(
            child: Text(
              items[subtitle],
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
