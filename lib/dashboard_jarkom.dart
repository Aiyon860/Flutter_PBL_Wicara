import 'package:flutter/material.dart';

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
      home: const DashboardJarkom(),
    );
  }
}

class DashboardJarkom extends StatelessWidget {
  const DashboardJarkom({super.key});

  @override
  Widget build(BuildContext context) {
    var height = View.of(context).physicalSize.height;
    var width = View.of(context).physicalSize.width;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: CustomColor.primaryColor,
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Icon(
              Icons.list,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 30,
            ),
            ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 10),
                      child: Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: CustomColor.bgNotificationBell),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.notifications,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            image: DecorationImage(
                              image: AssetImage("images/prof_pic.png"),
                              fit: BoxFit.cover,
                            )))
                  ],
                ))
          ])),
      body: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Stack(
            children: [
              Container(
                  width: width,
                  height: 250,
                  decoration: const BoxDecoration(
                    color: CustomColor.darkBlue,
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Container(
                  width: width,
                  height: height / 2.5,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(17.5),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        children: [
                          Container(
                              height: 50,
                              width: double.maxFinite,
                              decoration: const BoxDecoration(
                                  color: CustomColor.bgTransparentGrey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 7.5),
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(minHeight: 10),
                                      child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.search,
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                    child: Form(
                                        child: Row(
                                      children: [
                                        SizedBox(
                                          width: 300,
                                          child: TextFormField(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              hintText: "Ketikkan ID Laporan",
                                              hintStyle: TextStyle(
                                                decoration: TextDecoration.none,
                                                fontSize: 15,
                                                color: CustomColor.placeholderGrey,
                                              )
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return "Please enter some text";
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      ],
                                    )),
                                  )
                                ],
                              )),
                          const SizedBox(height: 30),
                          const DefaultTabController(
                            initialIndex: 0,
                            length: 3, 
                            child: TabBar(
                                  dividerHeight: 0,
                                  enableFeedback: true,
                                  tabs: [
                                    Tab(
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          "Belum ditemukan",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontSize: 13,
                                          )
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          "Ditemukan",
                                          style: TextStyle(
                                            fontSize: 13,
                                          )
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          "Hilang",
                                          style: TextStyle(
                                            fontSize: 13,
                                          )
                                        ),
                                      ),
                                    ),
                                  ]
                                )
                              )
                        ]
                      ),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}

class CustomColor {
  static const primaryColor = Color.fromRGBO(40, 121, 254, 1);
  static const btnGetStartedColor = Color.fromRGBO(0, 103, 255, 1);
  static const bgColorHome = Color.fromRGBO(239, 239, 239, 1);
  static const darkBlue = Color.fromRGBO(18, 64, 152, 1);
  static const bgNotificationBell = Color.fromRGBO(255, 255, 255, 0.100);
  static const bgTransparentGrey = Color(0xFFF7F8FA);
  static const placeholderGrey = Color(0xFFB0B0B1);
}

/*
  Color dalam bentuk Hex
  0xFF = tingkat opacity/transparansi
    Contoh: 0x00 = Full Transparan
            0xFF = Tidak Transparan sama sekali
  2879FE = 
    Contoh penggunaan: #2879FE;
  0xFF2879FE
 */