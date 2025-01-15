import "package:flutter/material.dart";
import "package:flutter_mobile_pbl/dashboard_kehilangan.dart";
import "package:flutter_mobile_pbl/detail_notifikasi.dart";
import "package:flutter_mobile_pbl/form_penemuan.dart";
import "package:flutter_mobile_pbl/home.dart";
import "package:flutter_mobile_pbl/profile_page.dart";
import "package:flutter_mobile_pbl/dashboard_pengaduan.dart";
import "custom_color.dart";
import "dashboard_notifikasi.dart";
import "dashboard_unit_layanan.dart";
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
        '/aduan': (context) => const AduanPage(),
        '/rating': (context) => const RatingScreenUser(),
        '/profile': (context) => const ProfilePage(),
        '/dashboard_notification': (context) => NotifikasiScreen(),
        '/notification_detail': (context) => const DetailNotificationScreen(),
        '/dashboard_kehilangan': (context) => const LostItemsScreen(),
        '/dashboard_unit_layanan': (context) => const DashboardUnitLayananPage(),
        '/form_penemuan': (context) => const UploadPenemuan(),
      },
    );
  }
}
