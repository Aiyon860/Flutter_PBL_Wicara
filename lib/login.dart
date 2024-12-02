import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

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
      home: const LoginPage(title: ''),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool? value = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Username atau password tidak boleh kosong";
      });
      return;
    }

    final url = Uri.parse(
        'http://10.0.2.2/wicara/backend/api/mobile/simpan_login_app.php');

    try {
      setState(() {
        _errorMessage = null;
      });

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          String token = data['token']; // Ambil token dari respons
          await saveToken(token); // Simpan token
          //await checkToken(); 

          setState(() {
            _errorMessage = 'berhasil';
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          setState(() {
            _errorMessage =
                data['message'] ?? 'Login gagal, periksa kredensial Anda';
          });
        }
      } else {
        print('Failed to connect. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _errorMessage = "Gagal menghubungi server, coba lagi nanti";
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _errorMessage =
            "Tidak dapat terhubung ke server. Periksa koneksi internet Anda.";
      });
    }
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    var height = View.of(context).physicalSize.height;
    var width = View.of(context).physicalSize.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.5,
                    decoration: const BoxDecoration(
                      color: CustomColor.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/login_pic.png",
                          height: MediaQuery.of(context).size.height / 6,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "WICARA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Wadah Informasi Catatan\nAspirasi & Rating Akademik.",
                          style: TextStyle(
                            color: Colors.white
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 40, 0, 40),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 35,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                    child: SizedBox(
                      width: width / 3.25,
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: "Masukkan nomor induk anda",
                          hintStyle:
                              TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: SizedBox(
                      width: width / 3.25,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Password",
                          hintStyle:
                              TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
                          prefixIcon: Icon(Icons.key),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
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
                          const Text("Ingat saya"),
                        ],
                      ),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(
                    width: width / 3.25,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.primaryColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      label: const Text(
                        "Masuk",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      icon: const Icon(Icons.login, color: Colors.white),
                      onPressed: login,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomColor {
  static const primaryColor = Color(0xFF2879FE);
}

