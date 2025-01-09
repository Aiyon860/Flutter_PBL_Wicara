import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/dashboard_kehilangan.dart';
import 'package:flutter_mobile_pbl/dashboard_unit_layanan.dart';
import 'package:flutter_mobile_pbl/dashboard_notifikasi.dart';
import 'custom_color.dart' as cc;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_color.dart';
import 'edit_profile_screen.dart';
import 'login.dart';
import 'home.dart';
import 'qr_scanner.dart';
import 'form_aduan.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String namaLengkap = '';
  String status = '';
  String nomorInduk = '';
  String bio = '';
  String jenisKelamin = '';
  String nomorTelepon = '';
  String role = '';
  String email = '';
  int notificationCount = 0;
  ImageProvider<Object> profile = const AssetImage('images/image_default.png');

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    fetchNotificationsCount();
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<bool> removeToken() async {
    final token = await getToken();
    final url = Uri.parse('https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/logout_app.php');
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', '');
    bool status = false;

    try {
      final response = await http.post(
        url, 
        headers: {'Content-Type': "application/x-www-form-urlencoded"},
        body: {'token': token}
      );
      status = (response.statusCode == 200);
    } catch (e) {
      print("Error removing token: $e");
    }

    return status;
  }

  Future<void> fetchProfileData() async {
    final token = await getToken();
    final url = Uri.parse('https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/tampil_profile_app.php');

    try {
      final response = await http.post(
        url, 
        headers: {'Content-Type': "application/x-www-form-urlencoded"},
        body: {'token': token}
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dataProfile = data["profile"];

        setState(() {
          namaLengkap = dataProfile['nama'] ?? 'Nama tidak ada';
          jenisKelamin = 
              dataProfile['jenis_kelamin'] == 'M' ? 'Laki-Laki' 
              : dataProfile['jenis_kelamin'] == 'F' ? 'Perempuan' 
              : 'Jenis Kelamin Tidak Ditemukan';
          nomorInduk =
              dataProfile['nomor_induk'] ?? 'Nomor Induk Tidak Ditemukan';
          nomorTelepon =
              dataProfile['nomor_telepon'] ?? 'Nomor Telepon Tidak Ditemukan';
          email = dataProfile['email'] ?? 'Email Tidak Ditemukan';
          role = dataProfile['nama_role'] ?? 'Role Tidak Ditemukan';
          bio = dataProfile['bio'] ?? 'Bio Tidak Ditemukan';
          profile = dataProfile['profile'] != null && dataProfile['profile'].isNotEmpty
            ? NetworkImage('https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/profile/${dataProfile["profile"]}')
            : const AssetImage('images/image_default.png');

        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  Future<bool> fetchNotificationsCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan di SharedPreferences');
    }

    Uri uri = Uri.parse(
        "https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/jumlah_notifikasi_app.php");

    final response = await http.post(
      uri,
      headers: {'Content-Type': "application/x-www-form-urlencoded"},
      body: {'token': token },
    );

    if (response.statusCode == 200) {
      setState(() {
        notificationCount = json.decode(response.body)["data"];
      });
      return true;
    } else {
      print('Error: ${response.statusCode}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.bgColorHome,
      appBar: AppBar(
        backgroundColor: CustomColor.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Your Profile',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            // Ganti dengan halaman yang ingin dituju
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const HomeScreen(), // Ganti dengan widget halaman yang Anda inginkan
              ),
            );
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              height: 30,
              width: 30,
              child: Stack(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.notifications,
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotifikasiScreen()),
                      );
                    },
                  ),
                  // Add the orange circle
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: notificationCount > 0 ? Colors.redAccent : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: CustomColor.darkBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90, // Adjust this for border thickness
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CustomColor.goldColor, // Border color
                        width: 2, // Thickness of the yellow border
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 80, // Inner circle size
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: profile, // Replace 'profile' with your image provider
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    namaLengkap,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  const SizedBox(height: 2.5),
                  Text(role,
                      style: const TextStyle(
                          fontSize: 14,
                          color: CustomColor.grayColor
                      )
                  ),
                  const SizedBox(height: 2.5),
                  Text(nomorInduk,
                      style: const TextStyle(
                          fontSize: 14,
                          color: CustomColor.grayColor
                      )
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 3.5,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // Shadow color
                            blurRadius: 6, // How much to blur the shadow
                            offset: const Offset(0, 4), // Offset x and y
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileInfo('Bio', bio),
                          _buildProfileInfo('Nama Lengkap', namaLengkap),
                          _buildProfileInfo('Jenis Kelamin', jenisKelamin),
                          _buildProfileInfo('Nomor Telepon', nomorTelepon),
                          _buildProfileInfo('Alamat Akun', email),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CustomColor.blackColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // Shadow color
                            blurRadius: 6, // How much to blur the shadow
                            offset: const Offset(0, 4), // Offset x and y
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            'Edit Profile',
                                () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                              ).then((value) {
                                if (value != null && value) {
                                  fetchProfileData(); // Ambil ulang data profil
                                }
                              });
                            },
                              true,
                            icon: Icons.edit
                          ),
                          const SizedBox(
                            height: 24,
                            child: VerticalDivider(
                              color: Colors.white, // Divider color
                              thickness: 1,          // Divider thickness
                              width: 20,             // Space between buttons
                            ),
                          ),
                          _buildActionButton(
                            'Log Out',
                                () async {
                              bool success = await removeToken();
                              // Delay navigation slightly to allow the snackbar to be visible
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const LoginPage(title: '',)),
                                  );
                                }
                              });
                            },
                            false,
                            icon: Icons.logout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, VoidCallback onPressed, bool isLeft, {IconData? icon}
      ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColor.blackColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: icon != null
          ? Icon(icon, color: Colors.white, size: 20)
          : const SizedBox.shrink(),
      label: Text(text, style: TextStyle(color: Colors.white, fontSize: 14)),
    );
  }
}
