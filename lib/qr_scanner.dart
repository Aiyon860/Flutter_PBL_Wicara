import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'form_rating.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Rute awal aplikasi
      routes: {
        '/': (context) => const QRScannerScreen(), // Halaman pemindaian QR
        '/rating': (context) => const RatingScreen(), // Halaman rating
      },
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  QRScannerScreenState createState() => QRScannerScreenState();
}

class QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  bool isFlashOn = false;
  final MobileScannerController cameraController = MobileScannerController();
  late AnimationController _animationController;
  bool hasScanned = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> verifyQR(String scannedQR) async {
    final url = Uri.parse('http://10.0.2.2/wicara/backend/api/mobile/check_qr_app.php'); // Pastikan alamat server sesuai

    try {
      final response = await http.post(
        url,
        body: json.encode({'namaQR': scannedQR}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          // QR cocok, pindah ke halaman rating menggunakan deep linking
          Navigator.pushNamed(context, '/rating');
        } else {
          // QR tidak cocok, tampilkan pesan
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kode QR tidak valid!')),
          );
        }
      } else {
        // Tampilkan pesan jika terjadi kesalahan pada permintaan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghubungi server!')),
        );
      }
    } catch (e) {
      print(e);
      // Tampilkan pesan jika terjadi kesalahan jaringan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kesalahan jaringan!')),
      );
    } finally {
      setState(() {
        hasScanned = false; // reset scanning state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text(
          'RATING LAYANAN',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
                cameraController.toggleTorch();
              });
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture barcodeCapture) {
              final barcodes = barcodeCapture.barcodes;
              if (barcodes.isNotEmpty && !hasScanned) {
                final String code = barcodes.first.rawValue ?? '';
                debugPrint('Barcode found! $code');
                setState(() {
                  hasScanned = true;
                });

                // Panggil fungsi verifyQR dengan code yang dipindai
                verifyQR(code);
              }
            },
          ),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(
                painter: BorderPainter(),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height / 2 - 125 +
                    (_animationController.value * 246),
                left: MediaQuery.of(context).size.width / 2 - 125,
                child: Container(
                  width: 250,
                  height: 4,
                  color: Colors.green,
                ),
              );
            },
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: const Center(
              child: Column(
                children: [
                  Text(
                    'Kode QR hanya berlaku untuk melakukan\nRating Unit Layanan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Perform any action on button press
                  },
                  child: const Text(
                    'SCAN HERE',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const double cornerLength = 20;

    canvas.drawLine(Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, 0), const Offset(0, cornerLength), paint);

    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    canvas.drawLine(
        Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}