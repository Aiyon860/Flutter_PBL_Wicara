// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _itemTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    final uri = Uri.parse('http://10.0.2.2/konfirm_barang/api/penemuan/simpan_penemuan.php');
    final request = http.MultipartRequest('POST', uri);

    request.fields['item_type'] = _itemTypeController.text;
    request.fields['description'] = _descriptionController.text;

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final responseData = jsonDecode(responseBody);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResponPenemuanScreen()),
        );
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
        backgroundColor: const Color(0xFF2879FE),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
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
            _buildTextField('Deskripsi', _descriptionController, isMultiline: true),
            const SizedBox(height: 16),
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
              onTap: _pickImage,
              child: _buildUploadField(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2879FE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Kirim',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isMultiline = false}) {
    return TextField(
      controller: controller,
      maxLines: isMultiline ? 4 : 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: Color(0xFFA5A5A5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2879FE)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildUploadField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF0F0F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_rounded,
              color: Color(0xFF858585),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedImage == null ? 'Upload File' : 'File Selected',
              style: const TextStyle(color: Color(0xFF858585), fontSize: 14, fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }
}
