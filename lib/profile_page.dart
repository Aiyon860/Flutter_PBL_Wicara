import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/notification_page.dart';
import 'custom_color.dart' as cc;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'login.dart';
import 'home.dart';
import 'qr_scanner.dart';
import 'buat_aduan.dart';
import 'dashboard_pengaduan.dart';

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
  ImageProvider<Object> profile = const AssetImage('images/image_default.png');

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        _selectedIndex = 0;
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateAduanForm()),
        );
        _selectedIndex = 0;
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScannerScreen()),
        );
        _selectedIndex = 0;
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        _selectedIndex = 0;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<bool> removeToken() async {
    final token = await getToken();
    final url = Uri.parse('http://10.0.2.2/wicara/backend/api/mobile/logout_app.php');
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
    final url = Uri.parse('http://10.0.2.2/wicara/backend/api/mobile/tampil_profile_app.php');

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
            ? NetworkImage('http://10.0.2.2/wicara/backend/profile/${dataProfile["profile"]}')
            : const AssetImage('images/image_default.png');

        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 40, 122, 254),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Akun',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF3A84FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 24),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: profile,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaLengkap,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(role,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                          Text(nomorInduk,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileInfo('Bio', bio),
                    _buildProfileInfo('Nama Lengkap', namaLengkap),
                    _buildProfileInfo('Jenis Kelamin', jenisKelamin),
                    _buildProfileInfo('Nomor Telepon', nomorTelepon),
                    _buildProfileInfo('Alamat Akun', email),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(
                          'Edit Profile',
                          Colors.blue,
                          Colors.white,
                          () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfileScreen()),
                          ).then((value) {
                            if (value != null && value) {
                              fetchProfileData(); // Ambil ulang data profil
                            }
                          });

                          },
                        ),
                        _buildActionButton(
                          'Log Out',
                          Colors.grey.shade300,
                          Colors.black45,
                          () async {
                            bool success = await removeToken();
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Log out berhasil')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Log out gagal')),
                              );
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage(title: '',)),
                            );
                          },
                          icon: Icons.logout,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: cc.CustomColor.darkBlue,
        unselectedItemColor: cc.CustomColor.liatAduanSayaFontColor,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cast),
            label: 'Jarkom',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_square),
            label: 'Buat Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            label: 'Scan Rating',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Unit Layanan',
          ),
        ],
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
      String text, Color color, Color textColor, VoidCallback onPressed,
      {IconData? icon}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: icon != null
          ? Icon(icon, color: textColor, size: 20)
          : const SizedBox.shrink(),
      label: Text(text, style: TextStyle(color: textColor, fontSize: 14)),
    );
  }

  Widget _buildDrawer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  _buildBodyDrawer(),
                  _buildTopBarDrawer(),
                  _buildFooterDrawer(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBarDrawer() {
    return Positioned(
      top: 0,
      child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: cc.CustomColor.borderGreyColor,
                width: 3.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Image.asset(
                    "images/wicara_black.png",
                    width: MediaQuery.of(context).size.width / 3,
                    height: 25,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: cc.CustomColor.liatAduanSayaFontColor,
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget _buildBodyDrawer() {
    return Container(
      decoration: const BoxDecoration(color: cc.CustomColor.bgTransparentGrey),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 85, 25, 25),
        child: Column(
          children: [
            _buildProfPicBodyDrawer(profile),
            const Divider(
              color: cc.CustomColor.anotherGrey,
              thickness: 1,
              height: 50,
            ),
            ..._buildMenuBodyDrawer(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfPicBodyDrawer(ImageProvider<Object> profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            image: DecorationImage(
              image: profile,
              fit: BoxFit.cover,
            ))),
        const SizedBox(width: 25),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                namaLengkap,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
              Text(role,
                  style: const TextStyle(
                    fontSize: 14,
                    color: cc.CustomColor.liatAduanSayaFontColor,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuBodyDrawer() {
    return [
      const ExpandableMenuItem(
        title: 'Profile',
        items: [], // Empty list for Profile since it has no sub-items
      ),
      ExpandableMenuItem(
        title: 'Pengaduan',
        items: [
          MenuItemData(
            title: 'Buat Aduan',
            page: const CreateAduanForm(),
          ),
          MenuItemData(
            title: 'Aduan Saya',
            page: const AduanPage(),
          ),
        ],
      ),
      ExpandableMenuItem(
        title: 'Kehilangan',
        items: [
          MenuItemData(
            title: 'Buat Laporan',
            page: const CreateAduanForm(), // TODO:placeholder
          ),
          MenuItemData(
            title: 'Jarkom Kehilangan',
            page: const CreateAduanForm(), // TODO:placeholder
          ),
        ],
      ),
    ];
  }

  Widget _buildFooterDrawer() {
    return Positioned(
      bottom: 0,
      child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: const BoxDecoration(
            color: cc.CustomColor.sidebarFooterBgColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "HUBUNGI KAMI",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Image.asset(
                      "images/instagram.png",
                      height: 25,
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      "images/phone.png",
                      height: 25,
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      "images/mail.png",
                      height: 25,
                    ),
                  ],
                ),
                const SizedBox(height: 45),
                const Text(
                  "Jl. Prof. Sudarto, Tembalang, Kec. Tembalang, Kota Semarang, Jawa Tengah 50275",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 35),
                Center(
                  child: Text("Copyright @${DateTime.now().year} POLINES",
                      style: const TextStyle(
                        color: cc.CustomColor.goldColor,
                        fontSize: 10,
                      )),
                ),
              ],
            ),
          )),
    );
  }
}
