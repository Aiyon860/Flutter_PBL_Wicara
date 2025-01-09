import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_pbl/home.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_color.dart';
import 'respon_aduan.dart';
import 'dart:convert'; // Tambahkan ini
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

typedef Progress = Function(double percent);

void main() {
  runApp(const CreateAduanApp());
}

class CreateAduanApp extends StatelessWidget {
  const CreateAduanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CreateAduanForm(),
    );
  }
}

class Laporan {
  String judul;
  String deskripsi;
  String jenisPengaduan;
  String namaInstansi;
  String lokasi;
  bool anonim; // Pastikan ini ada
  String? filePath;

  Laporan({
    required this.judul,
    required this.deskripsi,
    required this.jenisPengaduan,
    required this.namaInstansi,
    required this.lokasi,
    required this.anonim,
    this.filePath,
  });
}

class Instansi {
  final String id;
  final String name;

  Instansi({
    required this.id,
    required this.name,
  });

  // Factory constructor to create an instance from a map
  factory Instansi.fromJson(Map<String, dynamic> json) {
    return Instansi(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class JenisPengaduan {
  final String id;
  final String name;

  JenisPengaduan({
    required this.id,
    required this.name,
  });

  // Factory constructor to create an instance from a map
  factory JenisPengaduan.fromJson(Map<String, dynamic> json) {
    return JenisPengaduan(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}


class CreateAduanForm extends StatefulWidget {
  const CreateAduanForm({super.key});

  @override
  State<CreateAduanForm> createState() => _CreateAduanFormState();
}

class _CreateAduanFormState extends State<CreateAduanForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final String _nama = '';
  String _judul = '';
  String _desc = '';
  final String _jenis = '';
  String dropdownvalue = 'Item 1';

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  bool _anonim = false;
  File? _selectedImage;
  String? _selectedItemJenisPengaduan; // Menyimpan nilai dropdown
  String? _selectedItemInstansi; // Menyimpan nilai dropdown
  List<JenisPengaduan> jenisPengaduan = [];
  List<Instansi> instansi = [];

  Future<bool> fetchJenisPengaduan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan di SharedPreferences');
    }

    Uri uri = Uri.parse(
        "https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/tampil_jenis_pengaduan_form_aduan_app.php");

    final response = await http.post(
      uri,
      headers: {'Content-Type': "application/x-www-form-urlencoded"},
      body: {'token': token },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)["data"];
      setState(() {
        jenisPengaduan =
            data.map((item) => JenisPengaduan.fromJson(item)).toList();
      });
      return true;
    } else {
      print('Error: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> fetchInstansi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan di SharedPreferences');
    }

    Uri uri = Uri.parse(
        "https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/tampil_instansi_form_aduan_app.php");

    final response = await http.post(
      uri,
      headers: {'Content-Type': "application/x-www-form-urlencoded"},
      body: {'token': token },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)["data"];
      setState(() {
        instansi =
            data.map((item) => Instansi.fromJson(item)).toList();
      });
      return true;
    } else {
      print('Error: ${response.statusCode}');
      return false;
    }
  }

  void _submitForm() async {
    // Memastikan jenis pengaduan dipilih
    if (_selectedItemJenisPengaduan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih jenis pengaduan.')),
      );
      return;
    }

    // Membuat objek laporan
    Laporan laporan = Laporan(
      judul: _judulController.text,
      deskripsi: _deskripsiController.text,
      jenisPengaduan: _selectedItemJenisPengaduan!,
      namaInstansi: _selectedItemInstansi!,
      lokasi: _lokasiController.text,
      anonim: _anonim, // Pastikan ini benar
      filePath: _selectedImage?.path,
    );

    // Mengirim laporan dan menunggu hasil
    bool success = await kirimLaporan(laporan);

    // Menangani respons
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim!')),
      );

      // Navigasi ke halaman berikutnya jika pengiriman berhasil
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ResponAduan(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim laporan. Silakan coba lagi.')),
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
    super.initState();
    checkToken(); // Panggil checkToken untuk mengecek token di terminal saat laman ini dibuka
    fetchInstansi();
    fetchJenisPengaduan();
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
          'Buat Aduan',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16
          ),
        ),
        centerTitle: true,
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
                        controller: _judulController,
                        decoration: const InputDecoration(
                          labelText: 'Judul',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter your title.';
                          return null;
                        },
                        onSaved: (value) {
                          _judul = value!;
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
                          if (value!.isEmpty) {
                            return 'Please enter your description.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _desc = value!;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedItemJenisPengaduan,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedItemJenisPengaduan = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Jenis Pengaduan",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      items: jenisPengaduan.map<DropdownMenuItem<String>>(
                          (item) {
                        return DropdownMenuItem<String>(
                          value: item.id, // Simpan ID di sini
                          child: Text(item.name),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select Jenis Pengaduan.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedItemInstansi,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedItemInstansi = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Instansi",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      items: instansi.map<DropdownMenuItem<String>>(
                          (item) {
                        return DropdownMenuItem<String>(
                          value: item.id, // Simpan ID di sini
                          child: Text(item.name!),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select Instansi.';
                        }
                        return null;
                      },
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Checkbox untuk Anonim
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _anonim,
                          onChanged: (bool? value) {
                            setState(() {
                              _anonim = value!;
                            });
                          },
                          activeColor:
                              Colors.blue, // Warna checkbox saat dicentang
                        ),
                        const Text(
                          'Laporan akan disimpan tanpa identitas',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tombol Kirim
                    Container(
                      margin: EdgeInsets.only(bottom: 32),
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

Future<bool> kirimLaporan(Laporan laporan) async {
  var url = Uri.parse('https://toucan-outgoing-moderately.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/simpan_aduan_app.php');

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token'); // Ambil token yang tersimpan

  var request = http.MultipartRequest('POST', url);

  // Menambahkan fields ke dalam body, termasuk token
  request.fields['judul'] = laporan.judul;
  request.fields['deskripsi'] = laporan.deskripsi;
  request.fields['jenis_pengaduan'] = laporan.jenisPengaduan;
  request.fields['nama_instansi'] = laporan.namaInstansi;
  request.fields['lokasi'] = laporan.lokasi;
  request.fields['anonim'] = laporan.anonim ? '1' : '0';
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