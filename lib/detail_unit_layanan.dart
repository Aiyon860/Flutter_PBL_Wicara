import 'package:flutter/material.dart';
import 'custom_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CustomColor.primaryColor),
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      debugShowCheckedModeBanner: false,
      home: const ServiceUnitPage(),
      color: CustomColor.primaryColor,
    );
  }
}

class ServiceUnitPage extends StatelessWidget {
  const ServiceUnitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.bgGreyFormRating,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Unit Layanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0
          ),
        ),
        leading: const BackButton(
          color: Colors.white
        ),
        backgroundColor: CustomColor.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Section
            Stack(
              children: [
                Image.asset(
                  'images/upttik.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ],
            ),

            // Description Section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UPA TIK',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Icon(Icons.star_border, color: Colors.amber, size: 20),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('4/5'),
                      SizedBox(width: 8),
                      Text(
                        '120 Reviews',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Unit Penunjang Akademik Teknologi Informasi dan Komunikasi (UPA TIK) merupakan unit pendukung yang bertugas melaksanakan pengembangan, pengelolaan, dan pemberian layanan teknologi informasi dan komunikasi. \n\nUPA TIK berada dalam koordinasi Wakil Direktur Bidang Kerja Sama, Hubungan Masyarakat, dan Sistem Informasi.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30))
              ),
              child: Column(
                children: [
                  // Review Section
                  const Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Semua Ulasan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              
                  // Review Cards
                  ...List.generate(3, (index) => ReviewCard()),
              
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Lainnya'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Text('N', style: TextStyle(color: Colors.black)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star_border, color: Colors.amber, size: 16),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Select vertical selection project union layer. Variant layout prototype device bold selection content library.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
