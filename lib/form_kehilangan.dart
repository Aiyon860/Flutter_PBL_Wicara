import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/home.dart';
import 'package:flutter_mobile_pbl/respon_kehilangan.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // Tambahkan ini
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'api.dart';
import 'custom_color.dart';

typedef Progress = Function(double percent);

void main() {
  runApp(const CreateKehilanganApp());
}

class CreateKehilanganApp extends StatelessWidget {
  const CreateKehilanganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CreateKehilanganForm(),
    );
  }
}

class Laporan {
  String barang;
  String deskripsi;
  String tanggal;
  String lokasi;
  String? filePath;

  Laporan({
    required this.barang,
    required this.deskripsi,
    required this.tanggal,
    required this.lokasi,
    this.filePath,
  });
}

class CreateKehilanganForm extends StatefulWidget {
  const CreateKehilanganForm({super.key});

  @override
  State<CreateKehilanganForm> createState() => _CreateKehilanganFormState();
}

class _CreateKehilanganFormState extends State<CreateKehilanganForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String _barang = '';
  String _desc = '';

  final TextEditingController _barangController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  File? _selectedImage;

  String formatDate(String rawDate) {
    try {
      DateTime parsedDate =
      DateFormat("yyyy-MM-dd hh:mm a").parse(rawDate); // Format input
      return DateFormat("yyyy-MM-dd HH:mm:ss")
          .format(parsedDate); // Format output
    } catch (e) {
      print("Error parsing date: $e");
      return rawDate; // Jika parsing gagal, tetap kirimkan rawDate
    }
  }

  void _submitForm() async {
    if (_barangController.text.isEmpty || _deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data yang diperlukan.')),
      );
      return;
    }
    // Membuat objek laporan
    Laporan laporan = Laporan(
      barang: _barangController.text,
      deskripsi: _deskripsiController.text,
      tanggal: formatDate(_dateController.text),
      lokasi: _lokasiController.text,
      filePath: _selectedImage?.path,
    );

    // Mengirim laporan dan menunggu hasil
    bool success = await submitKehilangan(laporan);

    // Menangani respons
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim!')),
      );

      // Navigasi ke halaman berikutnya jika pengiriman berhasil
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ResponKehilangan(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gagal mengirim laporan. Silakan coba lagi.')),
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150, // Ketinggian pop-up
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Logika untuk memilih gambar dari kamera
                  Navigator.pop(context); // Menutup pop-up
                  _pickImageFromCamera(); // Tambahkan fungsi untuk memilih gambar dari kamera
                },
                child: const Text('Camera'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Logika untuk memilih gambar dari galeri
                  Navigator.pop(context); // Menutup pop-up
                  _pickImageFromGallery(); // Memilih gambar dari galeri
                },
                child: const Text('Gallery'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    checkToken(); // Panggil checkToken untuk mengecek token di terminal saat laman ini dibuka
    _dateController.text = "";
    super.initState();
  }

  Future<void> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      print('Token yang tersimpan aduan: $token');
    } else {
      print('Tidak ada token yang tersimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buat Laporan Kehilangan',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            // Ganti dengan halaman yang ingin dituju
            Navigator.pushNamed(context, '/home');
          },
        ),
        backgroundColor: CustomColor.darkBlue,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth > 600
              ? 100.0
              : 16.0, // padding lebih besar pada layar lebar
        ),
        children: [
          Center(
            child: Form(
              key: _formkey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: screenWidth > 600
                          ? 400
                          : double.infinity, // Lebar responsif
                      child: TextFormField(
                        controller: _barangController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Barang',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter your title.';
                          return null;
                        },
                        onSaved: (value) {
                          _barang = value!;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: screenWidth > 600
                          ? 400
                          : double.infinity, // Lebar responsif
                      child: TextFormField(
                        autofocus: true,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        controller: _deskripsiController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty)
                            return 'Please enter your description.';
                          return null;
                        },
                        onSaved: (value) {
                          _desc = value!;
                        },
                      ),
                    ),

                    //tanggal
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: screenWidth > 600 ? 400 : double.infinity,
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal',
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100));

                          if (pickedDate != null) {
                            // setState(() {
                            //   _dateController.text = pickedDate.toString().split(" ")[0];
                            // });
                            TimeOfDay? pickedTime = await showTimePicker(
                                context: context, initialTime: TimeOfDay.now());

                            if (pickedTime != null) {
                              setState(() {
                                DateTime finalDateTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute);
                                _dateController.text =
                                "${finalDateTime.toLocal().toString().split(' ')[0]} ${pickedTime.format(context)}";
                              });
                            } else {
                              print("Time is not selected");
                            }
                          } else {
                            print("Date is not selected");
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: screenWidth > 600
                          ? 400
                          : double.infinity, // Lebar responsif
                      child: TextFormField(
                        controller: _lokasiController,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi (Opsional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Unggah Gambar
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Unggah Gambar (Opsional)'),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: screenWidth > 600
                                ? 400
                                : double.infinity, // Lebar responsif
                            child: GestureDetector(
                              onTap: () {
                                _showImageSourceActionSheet(
                                    context); // Memanggil pop-up bottom sheet
                              },
                              child: Container(
                                height: 200, // Tinggi outer box
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black38,
                                      width: 1.3), // Outline border
                                  borderRadius: BorderRadius.circular(
                                      8), // Border radius untuk outer box
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _selectedImage == null
                                          ? Container(
                                        width:
                                        150, // Inner box tetap 150x150
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: CustomColor.darkBlue,
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.upload,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "Upload File",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                          : Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          child: Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Container(
                      width: screenWidth > 600
                          ? 300
                          : double.infinity, // Lebar responsif
                      decoration: BoxDecoration(
                        color: CustomColor.goldColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            _formkey.currentState!.save();
                            _submitForm();
                          } else {
                            print('Data tidak valid.');
                          }
                        },
                        child: const Text(
                          'Kirim',
                          style: TextStyle(
                              color: CustomColor.blackColor,
                              fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;

    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }

  Future _pickImageFromCamera() async {
    final returnedImage =
    await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) return;

    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }
}

Future<bool> submitKehilangan(Laporan laporan) async {
  var url = Uri.parse(ApiWicara.submitKehilanganUrl);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token'); // Ambil token yang tersimpan

  var request = http.MultipartRequest('POST', url);

  // Menambahkan fields ke dalam body, termasuk token
  request.fields['jenis_barang'] = laporan.barang;
  request.fields['deskripsi'] = laporan.deskripsi;
  request.fields['tanggal'] = laporan.tanggal;
  request.fields['lokasi'] = laporan.lokasi;
  request.fields['token'] = token ?? ''; // Token ditambahkan sebagai field di body

  // Menambahkan file jika ada
  if (laporan.filePath != null) {
    try {
      var file = await http.MultipartFile.fromPath('file', laporan.filePath!);
      request.files.add(file);

    } catch (e) {
      print("Error saat menambahkan file: $e");
      return false;
    }
  }

  // Mengirim request dan memproses respons
  var response = await request.send();

  // Mengonversi stream response ke String
  final respStr = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(respStr);
      return jsonResponse['status'] == 'success';
    } catch (e) {
      print('Error parsing JSON response: $e');
      print('Response: $respStr');
      return false;
    }
  } else {
    print('Error: ${response.statusCode}');
    print('Response Body: $respStr');
    return false;
  }
}
