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
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool? value = false;

  @override
  Widget build(BuildContext context) {
    var height = View.of(context).physicalSize.height;
    var width = View.of(context).physicalSize.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: CustomColor.primaryColor,
        title: const Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Image(
                  image: ExactAssetImage("images/login_pic.png"),
                  alignment: FractionalOffset.center,
                  width: 200,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  "WICARA",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                    letterSpacing: 0.75,
                  )
                ),
              ),
              Text(
                "Wadah Informasi Catatan\nAspirasi & Rating Akademik.", 
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                maxLines: 2,
              )
            ],
          ),
        ),
        toolbarHeight: height / 7,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30)
            )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 275, 0, 0),
        child: Center(
            child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: Text("Login",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 35,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                child: SizedBox(
                  width: width / 3.25,
                  child: TextFormField(
                    decoration: const InputDecoration(
                        hintText: "Masukkan username anda",
                        hintStyle: TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ))),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: SizedBox(
                  width: width / 3.25,
                  child: TextFormField(
                    decoration: const InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
                        prefixIcon: Icon(Icons.key),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ))),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                  child: SizedBox(
                    width: width / 3.25,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            value: value,
                            onChanged: (bool? newValue) {
                              setState(() {
                                value = newValue;
                              });
                            },
                            ),
                        const Text("Ingat saya")
                      ],
                    ),
                  )),
              SizedBox(
                width: width / 3.25,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.primaryColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      )),
                  label: const Text(
                    "Masuk",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {},
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}

class CustomColor {
  static const primaryColor = Color(0xFF2879FE);
}
