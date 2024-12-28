// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_color.dart';
import 'respon_penemuan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UploadPenemuan(),
    );
  }
}

class UploadPenemuan extends StatefulWidget {
  const UploadPenemuan({super.key});

  @override
  State<UploadPenemuan> createState() => _UploadPenemuanState();
}

class _UploadPenemuanState extends State<UploadPenemuan> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  int idKejadian = 0;
  bool _isDataFetched = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isDataFetched) {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      if (args != null) {
        setState(() {
          idKejadian = int.parse(args["id_kejadian"]);
        });
        _isDataFetched = true;
      }
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _submitForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan di SharedPreferences');
    }

    final uri = Uri.parse('https://affe-2404-8000-1038-2bf7-2d22-5e29-a5aa-1532.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/simpan_penemuan_app.php');
    final request = http.MultipartRequest('POST', uri);

    request.fields['token'] = token;
    request.fields['id_kejadian'] = idKejadian.toString();
    request.fields['deskripsi'] = _descriptionController.text;

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final responseData = jsonDecode(responseBody);
      if (responseData['status'] == 'success') {
        // Delay navigation slightly to allow the snackbar to be visible
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResponPenemuanScreen()),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server error, please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColor.darkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Upload Bukti Penemuan',
          style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTextField('Deskripsi', _descriptionController, isMultiline: true),
            const SizedBox(height: 24),
            const Text(
              'Unggah Gambar (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Color(0xFFA5A5A5),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _showImageSourceActionSheet(context);
              },
              child: _buildUploadField(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.goldColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Kirim',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isMultiline = false}) {
    return TextFormField(
      autofocus: true,
      controller: controller,
      maxLines: isMultiline ? 4 : 1,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: Color(0xFFA5A5A5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              color: CustomColor.darkBlue,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildUploadField() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage == null ?
            Container(
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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