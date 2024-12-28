import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_color.dart';
import 'home.dart';
import 'profile_page.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;
  late TextEditingController _namaLengkapController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  String jenisKelamin = 'Laki-Laki'; // Default sementara
  String? _profileUrl;

  @override
  void initState() {
    super.initState();
    _namaLengkapController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final url = Uri.parse('http://10.0.2.2/WICARA_FIX/Wicara_User_Web/backend/api/mobile/tampil_profile_app.php');

    try {
      final response = await http.post(url, body: {'token': token});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profileData = data["profile"];

        setState(() {
          _namaLengkapController.text = profileData['nama'] ?? '';
          _phoneNumberController.text = profileData['nomor_telepon'] ?? '';
          _emailController.text = profileData['email'] ?? '';
          _bioController.text = profileData['bio'] ?? '';
          jenisKelamin =
              profileData['jenis_kelamin'] == 'M' ? 'Laki-Laki' : 'Perempuan';
          _profileUrl = profileData['profile'] != null &&
                  profileData['profile'].isNotEmpty
              ? 'http://10.0.2.2/WICARA_FIX/Wicara_User_Web/backend/profile/${profileData["profile"]}'
              : null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil data profil.')),
        );
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat mengambil data.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<bool> updateProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final url = Uri.parse('http://10.0.2.2/WICARA_FIX/Wicara_User_Web/backend/api/mobile/update_profile_app.php');

  var request = http.MultipartRequest('POST', url);
  request.fields['token'] = token;
  request.fields['nama'] = _namaLengkapController.text;
  request.fields['nomor_telepon'] = _phoneNumberController.text;
  request.fields['email'] = _emailController.text;
  request.fields['bio'] = _bioController.text;
  request.fields['jenis_kelamin'] = jenisKelamin == 'Laki-Laki' ? 'M' : 'F';

  // Jika gambar profil tidak diubah, kirimkan nama file gambar profil lama
  if (_profileImage != null) {
    // Kirim gambar baru
    request.files.add(await http.MultipartFile.fromPath(
      'profile',
      _profileImage!.path,
    ));
  } else if (_profileUrl != null) {
    // Ambil nama file gambar setelah '/profile/'
    final imageName = _profileUrl?.split('/profile/').last;
    if (imageName != null) {
      request.fields['profile'] = imageName; // Kirimkan hanya nama file
    }
  }

  try {
    final response = await request.send();
    final responseData = await http.Response.fromStream(response);
    print('Response body: ${responseData.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      if (data['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } catch (e) {
    print('Error updating profile: $e');
    return false;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColor.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Ganti dengan halaman yang ingin dituju
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const ProfilePage(), // Ganti dengan widget halaman yang Anda inginkan
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 30),
              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Shadow color
                      blurRadius: 6, // How much to blur the shadow
                      offset: const Offset(0, 4), // Offset x and y
                    )],
                  ),
                  child: Column(
                    children: [
                      _buildForm(),
                    ],
                  )),
              const SizedBox(height: 30),
              _buildActionButton(
                'Simpan',
                CustomColor.goldColor,
                CustomColor.blackColor,
                () async {
                  bool success = await updateProfile();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil berhasil diperbarui.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal memperbarui profil.')),
                    );
                  }
                },
                icon: Icons.save, // Tambahkan ikon jika diinginkan
              ),
              const SizedBox(height: 10),
              _buildActionButton(
                            'Batal',
                            Colors.grey.shade300,
                            Colors.black45,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ProfilePage()),
                              );
                            },
                            icon: Icons.close,
                          ),
            ],
          ),
          ),
      ),
    );
  }
 
 Widget _buildProfileHeader() {
  return GestureDetector(
    onTap: _pickImage,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/Background.png"),
          fit: BoxFit.cover,
          ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : (_profileUrl != null
                    ? NetworkImage(_profileUrl!)
                    : const AssetImage('assets/Profiledefault.png')) as ImageProvider,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(4.0), // Background untuk ikon kamera
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}



  Widget _buildForm() {
    return Column(
      children: [
        TextField(
          controller: _namaLengkapController,
          decoration: const InputDecoration(
            labelText: 'Nama',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _phoneNumberController,
          decoration: const InputDecoration(
            labelText: 'Nomor Telepon',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _bioController,
          decoration: const InputDecoration(
            labelText: 'Bio',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 30),
        DropdownButtonFormField<String>(
          value: jenisKelamin,
          onChanged: (String? newValue) {
            setState(() {
              jenisKelamin = newValue!;
            });
          },
          items: ['Laki-Laki', 'Perempuan']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          decoration: const InputDecoration(
            labelText: 'Jenis Kelamin',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

Widget _buildActionButton(
    String text, Color color, Color textColor, VoidCallback onPressed,
    {IconData? icon}) {
  return SizedBox(
    width: double.infinity, // Membuat lebar tombol menjadi full
    child: ElevatedButton.icon(
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
    ),
  );
}
