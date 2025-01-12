import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'custom_color.dart';

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

    final url = Uri.parse(ApiWicara.loginUrl);

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
          if (data['token'] != null) {
            String token = data['token']; // Ambil token dari respons
            await saveToken(token); // Simpan token
          }

          setState(() {
            _errorMessage = 'berhasil';
          });

          if (data["user"]) {
            Navigator.pushNamed(context, '/home');
          } else if (data["super_admin"]) {
            Navigator.pushNamed(context, '/home_super_admin');
          } else {
            Navigator.pushNamed(context, '/home_admin_instansi');
          }
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/abstract-blue-galaxy-with-stars.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Black overlay for dimming effect
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4), // Adjust opacity to control dimming
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: SingleChildScrollView(
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 2.5,
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
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Wadah Informasi Catatan\nAspirasi & Rating Akademik.",
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height -
                            (MediaQuery.of(context).size.height / 2.5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
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
                                      hintStyle: TextStyle(
                                          color: Color.fromARGB(100, 0, 0, 0)),
                                      prefixIcon: Icon(Icons.person),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
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
                                      hintStyle: TextStyle(
                                          color: Color.fromARGB(100, 0, 0, 0)),
                                      prefixIcon: Icon(Icons.key),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                      ),
                                    ),
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
                              const SizedBox(height: 40),
                              SizedBox(
                                width: width / 3.25,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromRGBO(40, 121, 254, 1), // Custom blue
                                        Color(0xFF00008B), // Dark blue
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(15),
                                      onTap: login,
                                      child: const Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.login, color: Colors.white),
                                            SizedBox(width: 8),
                                            Text(
                                              "Masuk",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}