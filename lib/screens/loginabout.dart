import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:easy_agent/screens/login.dart';
import 'package:easy_agent/widgets/getonlineimage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginAboutPage extends StatefulWidget {
  const LoginAboutPage({Key? key}) : super(key: key);

  @override
  State<LoginAboutPage> createState() => _LoginAboutPageState();
}

class _LoginAboutPageState extends State<LoginAboutPage> {
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
            Get.offAll(() => const LoginView());
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
          const Padding(
            padding: EdgeInsets.all(18.0),
            child: Center(child: Text("App created by Havens Software Development, initiative of FNET",style: TextStyle(fontWeight: FontWeight.bold),)),
          ),
          const SizedBox(height: 20,),
          Container(
            width: 140.0,
            height: 140.0,
            margin: const EdgeInsets.only(
              top: 10.0,
              bottom: 14.0,
            ),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/png.png',
              width: 50,
              height: 50,
            ),
          ),
          const DefaultTextStyle(
            style: TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'App created by Havens Software Development'),
                ),

              ],
            ),
          ),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Click to "),
                      IconButton(
                        onPressed: (){
                          _callNumber();
                        },
                        icon: Image.asset("assets/images/telephone-call.png",width: 40,height: 40,),
                      ),
                      IconButton(
                        onPressed: () async{
                          launchWhatsapp(number: "+233550222888", message: "Hello 😀");
                        },
                        icon: myOnlineImage("assets/images/whatsapp.png",40,40),
                      ),
                    ],
                  ),
                ],
              )
          );
        },
        child: Image.asset("assets/images/customer-care.png"),
      ),
    );
  }
}
