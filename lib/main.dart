import "package:flutter/material.dart";
import "package:flutter_mobile_pbl/home.dart";
import "custom_color.dart";
import "form_rating.dart";
import "splash_screen.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wicara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CustomColor.primaryColor),
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      home: const SplashScreen(),
      initialRoute: '/', // Rute awal aplikasi
      routes: {
        '/home': (context) => const HomeScreen(),
        '/rating': (context) => const RatingScreen(), // Halaman rating
      },
    );
  }
}
