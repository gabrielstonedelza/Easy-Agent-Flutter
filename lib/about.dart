import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  void launchWhatsapp({@required number,@required message})async{
    String url = "whatsapp://send?phone=$number&text=$message";
    await canLaunch(url) ? launch(url) : Get.snackbar("Sorry", "Cannot open whatsapp",
        colorText: defaultWhite,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: snackBackground
    );
  }

  _callNumber() async{
    const number = '0550222888'; //set the number here
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Get.offAll(() => const Dashboard());
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("About Easy Agent"),
        backgroundColor: secondaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20,),
          Image.asset("assets/images/forapp.png",width: 100,height: 100,),
          const SizedBox(height: 20,),
          const Center(child: Text("Powered by",style: TextStyle(fontWeight: FontWeight.bold),)),
          const SizedBox(height: 20,),
          Image.asset("assets/images/logo.png",width: 70,height: 70,),
          const Padding(
            padding: EdgeInsets.only(top:8.0,left: 18),
            child: Center(child: Text("in partnership with Ghana Bankers Association of Ghana(ABAG)",style: TextStyle(fontWeight: FontWeight.bold),)),
          ),
          const SizedBox(height: 20,),
          Image.asset("assets/images/abaglogo.png",width: 70,height: 70,),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        onPressed: (){
          Get.defaultDialog(
            title: "Hi there 😃",
            content: Column(
              children: [
                // Lottie.asset("assets/images/hiwink.json",width: 80,height: 80),
               const Padding(
                 padding: EdgeInsets.only(left: 8.0),
                 child: Text("you can contact our customer service via "),
               ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: (){
                        _callNumber();
                      },
                      icon: Image.asset("assets/images/telephone-call.png",width: 40,height: 40,),
                    ),
                    IconButton(
                      onPressed: (){
                        launchWhatsapp(number:"+233550222888" ,message:"Hello from FNET");
                        Get.back();
                      },
                      icon: Image.asset("assets/images/whatsapp.png",width: 40,height: 40,),
                    ),
                  ],
                )
              ],
            )
          );
        },
        child: Image.asset("assets/images/customer-care.png"),
      ),
    );
  }
}
