import 'package:flutter/material.dart';
import "custom_color.dart";
import "login.dart";
import "custom_color.dart" as cc;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CustomColor.primaryColor),
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = View.of(context).physicalSize.width;

    return Scaffold(
        body: Stack(
      children: [
        Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage("images/splash_screen_bg.png"),
              fit: BoxFit.cover,
            ))),
        Center(
          child: Padding(
              padding: const EdgeInsets.all(50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Image(
                      image: ExactAssetImage("images/login_pic.png"),
                      alignment: Alignment.center,
                      width: 300,
                    ),
                  ),
                  const SizedBox(height: 135),
                  const Text(
                    "Selamat Datang !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 27.5,
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    "Wadah Informasi Catatan Aspirasi &\nRating Akademik.",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 75),
                  SizedBox(
                    width: width / 3.25,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                      label: const Text(
                        "Get Started",
                        style: TextStyle(
                          color: cc.CustomColor.btnGetStartedColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(title: ''),
                            ));
                      },
                    ),
                  )
                ],
              )),
        )
      ],
    ));
  }
}
