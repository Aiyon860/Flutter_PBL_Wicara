import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/dashboard_kehilangan.dart';
import 'package:flutter_mobile_pbl/form_kehilangan.dart';
import 'package:flutter_mobile_pbl/dashboard_notifikasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import "custom_color.dart";
import "form_aduan.dart";
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'detail_unit_layanan.dart';
import 'images_default.dart';
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
  String nama = "";
  String role = "";
  ImageProvider<Object> profilePicture = const AssetImage(DefaultImage.profilePicturePath);
  int jumlahNotifikasi = 0;

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
          MaterialPageRoute(builder: (context) => const LostItemsScreen()),
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
    fetchNotificationsCount();
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
          title: TopBar(
              nama: nama,
              role: role,
              profilePicture: profilePicture,
              jumlahNotifikasi: jumlahNotifikasi),
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
          }),
      ),
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
                      width: MediaQuery.of(context).size.width,
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
                                    const Text(
                                        "Aduan Saya",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        )
                                    ),
                                    const SizedBox(height: 10),
                                    aduanTerbaru.isEmpty
                                        ? const Padding(
                                          padding: EdgeInsets.only(top: 16.0),
                                          child: Center(
                                            child: Text(
                                          "Tidak ada aduan",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                                                                ),
                                                                              ),
                                        )
                                        :
                                    Column(
                                      children: [
                                        aduanTerbaru.isEmpty
                                            ? Column(
                                          children: List.generate(1, (index) => const Center(child: CircularProgressIndicator())),
                                        )
                                            : Column(
                                          children: List.generate(aduanTerbaru.length > 3 ? 3 : aduanTerbaru.length, (index) {
                                            final aduan = aduanTerbaru[index];
                                            return _buildPreviewAduanSaya(
                                              index + 1,
                                              aduan["judul"],
                                              aduan["nama_jenis_pengaduan"],
                                              aduan["tanggal"],
                                              aduan["nama_status_pengaduan"],
                                              aduan["lampiran"] ?? DefaultImage.aduanKehilanganPath,
                                              aduan["image_exist"],
                                            );
                                          }),
                                        ),
                                        if (aduanTerbaru.length > 3)
                                          _buildTampilkanLebihBanyakButton(const AduanPage())
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                            "Lihat Aduan dan Laporan",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            )
                                        ),
                                        Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                6,
                                            width: double.infinity,
                                            decoration: const BoxDecoration(
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
                                                  "Aduan\nSaya",
                                                  const Color(0xFF124098),
                                                  Colors.white,
                                                  Icons.assignment,
                                                  const Color(0x55F2E9FF),
                                                  "circle_stripe.png",
                                                  const AduanPage(),
                                                ),
                                                const SizedBox(width: 10),
                                                _buildMenuLihatAduan(
                                                  "Jarkom\nKehilangan",
                                                  const Color(0xFFFFB903),
                                                  Colors.black,
                                                  Icons.announcement,
                                                  const Color(0xDDFFF1CE),
                                                  "oval_vertical_ascending.png",
                                                  const LostItemsScreen(),
                                                ),
                                                const SizedBox(width: 10),
                                                _buildMenuLihatAduan(
                                                  "Rating\nInstansi",
                                                  const Color(0xFF191919),
                                                  Colors.white,
                                                  Icons.thumb_up,
                                                  const Color(0x55F2E9FF),
                                                  "circles_dots.png",
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
                                          const Text(
                                              "Unit Layanan",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                              )
                                          ),
                                          const SizedBox(height: 10),
                                          Column(children: [
                                            ...List.generate(unitLayanan.length > 3 ? 3 : unitLayanan.length,
                                                (index) {
                                              final unit = unitLayanan[index];
                                              return _buildUnitLayananPreview(
                                                  int.parse(unit["id_instansi"]),
                                                  unit["nama_instansi"],
                                                  unit["website"] ?? '-',
                                                  unit["rata_rata_rating"] == 0 ? 0 : int.parse(unit["rata_rata_rating"]),
                                                  unit["total_rating"] == 0 ? 0 : int.parse(unit["total_rating"]),
                                                  unit["image_exist"],
                                                  unit["gambar_instansi"],
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
        enableFeedback: true,
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
            icon: Icon(Icons.home),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan di SharedPreferences');
    }

    Uri uri = Uri.parse(ApiWicara.fetchDataUnitLayananHomeUrl);

    final response = await http.post(
      uri,
      headers: {'Content-Type': "application/x-www-form-urlencoded"},
      body: {'token': token },
    );

    if (response.statusCode == 200) {
      setState(() {
        unitLayanan = json.decode(response.body)["data"];
      });
      return true;
    } else {
      print('Error: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> fetchNotificationsCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan di SharedPreferences');
    }

    Uri uri = Uri.parse(ApiWicara.fetchNotificationCountUrl);

    final response = await http.post(
      uri,
      headers: {'Content-Type': "application/x-www-form-urlencoded"},
      body: {'token': token },
    );

    if (response.statusCode == 200) {
      setState(() {
        jumlahNotifikasi = json.decode(response.body)["data"];
      });
      return true;
    } else {
      print('Error: ${response.statusCode}');
      return false;
    }
  }

  Widget _buildUnitLayananPreview(
      int index,
      String nama,
      String website,
      int rataRataRating,
      int totalRating,
      bool imageExist,
      String lampiran
  ) {

    return InkWell(
      onTap: () {
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UnitLayananScreen(idInstansi: index.toString()),
            ),
          );
        });
      },
      child: Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          width: double.infinity,
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
                      child: (imageExist
                          ? Image.network(
                            lampiran,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 4,
                            fit: BoxFit.cover,)
                          : Image.asset(
                        "images/detail_unit_layanan_picture_default.png",
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 4,
                        fit: BoxFit.cover,
                            ))
                  ),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          CustomColor.darkBlue.withOpacity(0.6),
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
                          '$rataRataRating/5',
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
                              '$totalRating Review${totalRating > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: CustomColor.liatAduanSayaFontColor,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.goldColor,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Optional: Adjust button shape
                        ),
                      ),
                      onPressed: () {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UnitLayananScreen(idInstansi: index.toString()),
                            ),
                          );
                        });
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min, // Minimizes the width of the button
                        children: [
                          Text(
                            "Detail",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16, // Optional: Adjust font size
                            ),
                          ),
                          SizedBox(width: 4), // Adjust spacing between Text and Icon
                          Icon(
                            Icons.chevron_right_outlined,
                            color: Colors.black,
                            size: 20, // Adjust size of the icon
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildMenuLihatAduan(
      String label,
      Color backgroundColor,
      Color textAndIconColor,
      IconData icon,
      Color circleColor,
      String additionalDecorationPath,
      Widget nextPage) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: backgroundColor,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextPage),
          );
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.grey.withOpacity(0.3),
        child: Container(
          width: MediaQuery.of(context).size.width / 3.6,
          height: MediaQuery.of(context).size.height / 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // Match the overall shape
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0), // Padding for text and icon
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: circleColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: textAndIconColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textAndIconColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -10, // Align with the very top of the container
                  right: 0, // Align with the right edge
                  child: Opacity(
                    opacity: (
                        textAndIconColor != Colors.black ? 0.7 : 1.0),
                    child: Image.asset(
                      "images/$additionalDecorationPath",
                      height: MediaQuery.of(context).size.height / 12,
                      width: MediaQuery.of(context).size.width / 10,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan di SharedPreferences');
    }

    Uri uri = Uri.parse(ApiWicara.fetchDataAduanTerbaruUrl);

    final response = await http.post(
      uri,
      headers: {'Content-Type': "application/x-www-form-urlencoded"},
      body: {'token': token },
    );

    if (response.statusCode == 200) {
      setState(() {
        aduanTerbaru = json.decode(response.body)["data"];
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
      bool imageExist,
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
        child: Column(children: [
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
            ClipRRect(
              borderRadius: BorderRadius.circular(10), // Set the border radius
              child: imageExist
                  ? Image.network(
                    lampiran,
                    height: MediaQuery.of(context).size.height / 15,
                    width: MediaQuery.of(context).size.width / 6.5,
                    fit: BoxFit.cover,
                  )
                  : Image.asset(
                    DefaultImage.aduanKehilanganPath,
                    height: MediaQuery.of(context).size.height / 15,
                    width: MediaQuery.of(context).size.width / 6.5,
                    fit: BoxFit.cover,
                  ),
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
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
            ),
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

    Uri url = Uri.parse(ApiWicara.fetchUserDataHomeUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': "application/x-www-form-urlencoded"},
      body: {'token': token},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dataProfile = data["data"];

      setState(() {
        nama = dataProfile["nama"] ?? "Nama tidak ada";
        role = dataProfile["nama_role"] ?? "Role tidak ditemukan";
        profilePicture = dataProfile["image_exist"]
            ? NetworkImage(dataProfile["profile"])
            : const AssetImage(DefaultImage.profilePicturePath);
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
            _buildProfPicBodyDrawer(nama, role, profilePicture),
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

  Widget _buildProfPicBodyDrawer(
      String username,
      String jabatan,
      ImageProvider<Object> profpic) {
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
      ExpandableMenuItem(
        title: 'Pengaduan',
        icon: Icons.assignment, // Add this line
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
        icon: Icons.announcement, // Add this line
        items: [
          MenuItemData(
            title: 'Buat Laporan',
            page: const CreateKehilanganForm(),
          ),
          MenuItemData(
            title: 'Jarkom Kehilangan',
            page: const LostItemsScreen(),
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
                  "Jl. Prof. Sudarto, Tembalang, Kec. Tembalang, Kota Semarang, Jawa Tengah 50275",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 35),
                Row(
                  children: [
                    Text("Copyright @${DateTime.now().year} POLINES",
                        style: const TextStyle(
                          color: CustomColor.goldColor,
                          fontSize: 10,
                        )),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class TopBar extends StatefulWidget {
  final String nama;
  final String role;
  final ImageProvider profilePicture;
  final int jumlahNotifikasi;

  const TopBar({
    super.key,
    required this.nama,
    required this.role,
    required this.profilePicture,
    required this.jumlahNotifikasi,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Add the "Home" text
        const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            "Home",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
        ),
        // Notification icon and profile picture on the right
        Row(
          children: [
            _buildNotificationIcon(widget.jumlahNotifikasi),
            const SizedBox(width: 10),
            _buildProfPicIcon(widget.profilePicture),
          ],
        ),
      ],
    );
  }


  Widget _buildNotificationIcon(int notificationsCount) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: CustomColor.bgNotificationBell,
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
                  color: notificationsCount > 0 ? Colors.redAccent : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfPicIcon(ImageProvider profilePicture) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
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
                image: profilePicture,
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
  final IconData icon; // Add this line
  final VoidCallback? onTitleTap;

  const ExpandableMenuItem({
    super.key,
    required this.title,
    required this.items,
    required this.icon, // Add this line
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
                Icon(widget.icon, size: 20), // Display the icon
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
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
                      ),
                      child: Text(
                        item.title,
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