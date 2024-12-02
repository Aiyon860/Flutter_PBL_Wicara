import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/notification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "custom_color.dart";
import "buat_aduan.dart";
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'detail_unit_layanan.dart';
import 'qr_scanner.dart';
import 'dashboard_pengaduan.dart';
import 'profile_page.dart';
import 'dashboard_unit_layanan.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CustomColor.primaryColor),
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  List unitLayanan = [];
  List aduanTerbaru = [];
  List userData = [];

  final List<String> imagePaths = [
    "images/dashboard_slide1.png",
    "images/dashboard_slide2.png",
    "images/dashboard_slide3.png"
  ];

  late List<Widget> _pages;
  int _activePage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;
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
          MaterialPageRoute(builder: (context) => const DashboardUnitLayananPage()),
        );
        _selectedIndex = 0;
        break;
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (_pageController.page == imagePaths.length - 1) {
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut);
        } else {
          _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = List.generate(imagePaths.length,
        (index) => ImagePlaceholder(imagePath: imagePaths[index]));
    startTimer();
    fetchDataUnitLayanan();
    fetchDataAduanTerbaru();
    fetchUserDataHome();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0);

  void _scrollToPosition() {
    _scrollController.animateTo(
      (MediaQuery.of(context).size.height / 4) +
          20, // Adjust this value to the desired scroll position
      duration: const Duration(milliseconds: 750),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.bgColorHome,
      drawer: _buildDrawer(),
      appBar: AppBar(
          backgroundColor: CustomColor.primaryColor,
          title: TopBar(userData: userData),
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.list,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          })),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Stack(
              children: [
                Stack(children: [
                  SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 4,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imagePaths.length,
                        onPageChanged: (value) {
                          setState(() {
                            _activePage = value;
                          });
                        },
                        itemBuilder: (context, index) {
                          // return image widget
                          return _pages[index];
                        },
                      )),
                  Positioned(
                    bottom: 55,
                    left: 0,
                    right: 0,
                    child: Container(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              _pages.length,
                              (index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: InkWell(
                                    onTap: () {
                                      if (_pageController.hasClients) {
                                        _pageController.animateToPage(index,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeIn);
                                      }
                                    },
                                    child: IgnorePointer(
                                      child: CircleAvatar(
                                        radius: (_activePage == index ? 6 : 4),
                                        backgroundColor: (_activePage == index
                                            ? Colors.white
                                            : CustomColor.placeholderGrey),
                                      ),
                                    ),
                                  ))),
                        )),
                  ),
                ]),
                Padding(
                  padding: EdgeInsets.only(
                      top: (MediaQuery.of(context).size.height / 4) - 25),
                  child: SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 2.2,
                      child: Container(
                          decoration: const BoxDecoration(
                            color: CustomColor.bgColorHome,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Aduan Saya"),
                                    const SizedBox(height: 10),
                                    ...List.generate(aduanTerbaru.length,
                                        (index) {
                                      final aduan = aduanTerbaru[index];
                                      return _buildPreviewAduanSaya(
                                          index + 1,
                                          aduan["judul"],
                                          aduan["nama_jenis_pengaduan"],
                                          aduan["tanggal"],
                                          aduan["nama_status_pengaduan"],
                                          aduan["lampiran"]);
                                    }),
                                    _buildTampilkanLebihBanyakButton(const AduanPage()),
                                    const SizedBox(height: 30),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Lihat Aduan"),
                                        const SizedBox(height: 10),
                                        Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                6,
                                            width: double.infinity,
                                            decoration: const BoxDecoration(
                                              color: CustomColor
                                                  .liatAduanSayaBgColor,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                _buildMenuLihatAduan(
                                                  "images/aduan_ulasan.png",
                                                  "Aduan\nSaya",
                                                  const AduanPage(),
                                                ),
                                                const SizedBox(width: 10),
                                                _buildMenuLihatAduan(
                                                  "images/jarkom.png",
                                                  "Jarkom\nKehilangan",
                                                  const CreateAduanForm(),
                                                ),
                                                const SizedBox(width: 10),
                                                _buildMenuLihatAduan(
                                                  "images/aduan_ulasan.png",
                                                  "Rating\nUnit Layanan",
                                                  const QRScannerScreen(),
                                                ),
                                              ],
                                            ))
                                      ],
                                    ),
                                    const SizedBox(height: 50),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Rating Unit Layanan"),
                                          const SizedBox(height: 10),
                                          Column(children: [
                                            ...List.generate(3,
                                                (index) {
                                              final unit = unitLayanan[index];
                                              return _buildUnitLayananPreview(
                                                  unit["nama_instansi"],
                                                  unit["website"],
                                                  unit["rata_rata_rating"] == 0.0 ? 0.0 : double.parse(unit["rata_rata_rating"]),
                                                  unit["total_rating"] == 0 ? 0 : int.parse(unit["total_rating"]),
                                                );
                                            }),
                                            // _buildTampilkanLebihBanyakButton(),
                                          ]),
                                        ]),
                                    _buildTampilkanLebihBanyakButton(const DashboardUnitLayananPage()),
                                  ],
                                ),
                              ],
                            ),
                          ))),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: (MediaQuery.of(context).size.height / 4) - 45),
                  child: Center(
                    child: SizedBox(
                        width: 250,
                        height: 40,
                        child: Material(
                          color: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            splashColor: Colors.blue
                                .withOpacity(0.3), // Customize splash color
                            highlightColor:
                                Colors.transparent, // Customize highlight color
                            onTap: _scrollToPosition, // Trigger scroll on tap
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: CustomColor.liatAduanSayaBgColor,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Lihat Aduan Saya Terbaru",
                                    style: TextStyle(
                                      color: CustomColor.liatAduanSayaFontColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_double_arrow_down_outlined,
                                    size: 12,
                                    color: CustomColor.liatAduanSayaFontColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )),
                  ),
                )
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: CustomColor.darkBlue,
        unselectedItemColor: CustomColor.liatAduanSayaFontColor,
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

  Future<bool> fetchDataUnitLayanan() async {
    Uri uri = Uri.parse(
        "http://10.0.2.2/wicara/backend/api/mobile/ambil_data_unit_layanan_home_app.php");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      setState(() {
        unitLayanan = json.decode(response.body);
      });
      return true;
    } else {
      print('Error: ${response.statusCode}');
      return false;
    }
  }

  Widget _buildUnitLayananPreview(
    String nama, 
    String website,
    double rataRataRating,
    int totalRating
  ) {
    String imagePath;

    if (nama == "UPA TIK") {
      imagePath = "images/upttik.png";
    } else if (nama == "UPA Perpustakaan") {
      imagePath = "images/perpus.jpg";
    } else {
      imagePath = "images/poliklinik.png";
    }

    return Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        width: double.infinity,
        height: (MediaQuery.of(context).size.height / 3),
        decoration: BoxDecoration(
            color: CustomColor.liatAduanSayaBgColor,
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7.5,
                offset: const Offset(0, 2),
              )
            ]),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Image(
                      image: ExactAssetImage(imagePath),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 4,
                      fit: BoxFit.cover,
                    )),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        CustomColor.darkBlue.withOpacity(0.5),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
                Positioned(
                    bottom: 10,
                    left: 10,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        Text(
                          website,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        '$rataRataRating/5.0',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Column(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rataRataRating ? Icons.star : Icons.star_border,
                                color: CustomColor.goldColor,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$totalRating Reviews',
                            style: const TextStyle(
                              fontSize: 16,
                              color: CustomColor.liatAduanSayaFontColor,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ServiceUnitPage()),
                      );
                    },
                    child: const Row(
                      children: [
                        Text("Detail",
                            style: TextStyle(
                              color: Colors.black,
                            )),
                        Icon(
                          Icons.chevron_right_outlined,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildMenuLihatAduan(String path, String label, Widget nextPage) {
    return Material(
      color: Colors
          .transparent, // Set background color to transparent for the ripple effect to be visible
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextPage),
          );
        },
        borderRadius: BorderRadius.circular(8), // Set radius for ripple effect
        splashColor:
            Colors.grey.withOpacity(0.3), // Customize ripple color if needed
        child: Container(
          width: MediaQuery.of(context).size.width / 4,
          height: MediaQuery.of(context).size.height / 7,
          decoration: const BoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                path,
                width: MediaQuery.of(context).size.width / 4,
                height: (MediaQuery.of(context).size.height / 10) - 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTampilkanLebihBanyakButton(Widget destinationPage) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Tampilkan lebih banyak",
            style: TextStyle(
              color: CustomColor.liatAduanSayaFontColor,
            ),
          ),
          Icon(
            Icons.keyboard_double_arrow_down_outlined,
            color: CustomColor.liatAduanSayaFontColor,
          )
        ],
      ),
    );
  }

  Future<bool> fetchDataAduanTerbaru() async {
    Uri uri = Uri.parse(
        "http://10.0.2.2/wicara/backend/api/mobile/ambil_data_aduan_terbaru_app.php");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      setState(() {
        aduanTerbaru = json.decode(response.body);
      });
      return true;
    } else {
      print('Error: ${response.statusCode}');
      return false;
    }
  }

  String formatDate(String mysqlDatetime) {
    DateTime parsedDate = DateTime.parse(mysqlDatetime);
    String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
    return formattedDate;
  }

  String capitalizeFirstLetter(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }

  Widget _buildPreviewAduanSaya(
    int index,
    String judul,
    String jenisAduan,
    String tanggal,
    String status,
    String lampiran,
  ) {
    Color selectedColor;

    if (status == "Selesai") {
      selectedColor = CustomColor.selesaiColor;
    } else if (status == "Diproses") {
      selectedColor = CustomColor.goldColor;
    } else if (status == "Ditolak" || status == "Dibatalkan") {
      selectedColor = CustomColor.requiredColor;
    } else {
      selectedColor = CustomColor.liatAduanSayaFontColor;
    }

    String judulCapitalized = judul;
    List<String> judulSplitted = judul.split(' ');

    if (judulSplitted.length > 1) {
      judulCapitalized =
          judulSplitted.map((word) => capitalizeFirstLetter(word)).join(' ');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 6,
      decoration: BoxDecoration(
          color: CustomColor.liatAduanSayaBgColor,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7.5,
              offset: const Offset(0, 2),
            )
          ]),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("No. $index"),
              ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 5, minHeight: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 14,
                        color: selectedColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ))
            ],
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Image.asset(
              "images/ac.png",
              height: MediaQuery.of(context).size.height / 10,
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judulCapitalized,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                Text(jenisAduan,
                    style: const TextStyle(
                      color: CustomColor.liatAduanSayaFontColor,
                    )),
                Row(
                  children: [
                    const Text("Tanggal Upload",
                        style: TextStyle(
                          color: CustomColor.liatAduanSayaFontColor,
                        )),
                    const SizedBox(width: 5),
                    Text(
                      formatDate(tanggal),
                    ),
                  ],
                )
              ],
            )
          ]),
        ]),
      ),
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
                color: CustomColor.borderGreyColor,
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
                    color: CustomColor.liatAduanSayaFontColor,
                  ),
                )
              ],
            ),
          )),
    );
  }

  Future<bool> fetchUserDataHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan di SharedPreferences');
    }

    Uri url = Uri.parse("http://10.0.2.2/wicara/backend/api/mobile/ambil_data_user_home_app.php");
    final response = await http.post(
      url,
      headers: {'Content-Type': "application/x-www-form-urlencoded"},
      body: {'token': token},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dataProfile = data["data"];

      var user = <String, dynamic>{};
      user["nama"] = dataProfile["nama"] ?? "Nama tidak ada";
      user["role"] = dataProfile["nama_role"] ?? "Role tidak ditemukan";
      user["profile"] = dataProfile["profile"] != null && dataProfile["profile"].isNotEmpty 
        ? NetworkImage('http://10.0.2.2/wicara/backend/profile/${dataProfile["profile"]}')
        : const AssetImage('images/image_default.png');

      setState(() {
        userData.add(user);
      });

      return true;
    } else {
      print('Error: ${response.statusCode}');
      return false;
    }
  }

  Widget _buildBodyDrawer() {
    return Container(
      decoration: const BoxDecoration(color: CustomColor.bgTransparentGrey),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 85, 25, 25),
        child: Column(
          children: [
            _buildProfPicBodyDrawer(userData[0]["nama"], userData[0]["role"], userData[0]["profile"]),
            const Divider(
              color: CustomColor.anotherGrey,
              thickness: 1,
              height: 50,
            ),
            ..._buildMenuBodyDrawer(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfPicBodyDrawer(String username, String jabatan, ImageProvider<Object> profpic) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
          child: Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              image: DecorationImage(
                image: profpic,
                fit: BoxFit.cover,
              )
              )
            ),
        ),
        const SizedBox(width: 25),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
              Text(jabatan,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CustomColor.liatAduanSayaFontColor,
                    fontWeight: FontWeight.w300,
                  ),
                  softWrap: true,
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
            page: const AduanPage(), // TODO:placeholder
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
            color: CustomColor.sidebarFooterBgColor,
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
                        color: CustomColor.goldColor,
                        fontSize: 10,
                      )),
                ),
              ],
            ),
          )),
    );
  }
}

class TopBar extends StatefulWidget {
  final List userData;

  const TopBar({
    super.key,
    required this.userData,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const SizedBox(width: 30),
      ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNotificationIcon(),
              const SizedBox(width: 10),
              _buildProfPicIcon(widget.userData),
            ],
          ))
    ]);
  }

  Widget _buildNotificationIcon() {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: CustomColor.bgNotificationBell),
      child: SizedBox(
          height: 30,
          width: 30,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.notifications,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 25,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  NotificationsPage()),
              );
            },
          )),
    );
  }

  Widget _buildProfPicIcon(List<dynamic> userData) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      },
      child: Ink(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              image: DecorationImage(
                image: userData[0]["profile"],
                fit: BoxFit.cover,
              ))),
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  final String? imagePath;
  const ImagePlaceholder({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath!,
      fit: BoxFit.cover,
    );
  }
}

class ExpandableMenuItem extends StatefulWidget {
  final String title;
  final List<MenuItemData> items;
  final VoidCallback? onTitleTap;

  const ExpandableMenuItem({
    super.key,
    required this.title,
    required this.items,
    this.onTitleTap,
  });

  @override
  State<ExpandableMenuItem> createState() => _ExpandableMenuItemState();
}

// Class to hold menu item data
class MenuItemData {
  final String title;
  final Widget page;

  MenuItemData({required this.title, required this.page});

  Widget build(BuildContext context) {
    return Text(title);
  }
}

class _ExpandableMenuItemState extends State<ExpandableMenuItem> {
  bool _isExpanded = false;

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main button
        InkWell(
          onTap: () {
            if (widget.items.isNotEmpty) {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Only show arrow if there are items
                if (widget.items.isNotEmpty)
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        // Dropdown items
        if (widget.items.isNotEmpty)
          AnimatedCrossFade(
            firstChild: Container(height: 0),
            secondChild: Column(
              children: widget.items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(
                        left: 32,
                        right: 16,
                        top: 4,
                        bottom: 4,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => _navigateToPage(context, item.page),
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            "• ${item.title}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
      ],
    );
  }
}
