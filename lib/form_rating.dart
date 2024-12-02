import 'dart:io';
import 'package:flutter/material.dart';
import "custom_color.dart";
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating/flutter_rating.dart';
import "package:http/http.dart" as http;
import "dart:convert";

class FormRating extends StatelessWidget {
  const FormRating({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CustomColor.primaryColor),
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      home: const RatingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  RatingScreenState createState() => RatingScreenState();
}

class RatingScreenState extends State<RatingScreen> {
  bool? hideIdentity = false;
  double rating = 0;
  String imageName = '';
  File? _selectedImage;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Stack(
          children: [
            _buildBackgroundImage(),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildFormContainer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pushNamed(context, '/home'),
      ),
      backgroundColor: CustomColor.bgGreyFormRating,
      elevation: 0,
    );
  }

  Widget _buildBackgroundImage() {
    return const Positioned(
      right: 0,
      top: 40,
      child: Image(
        image: ExactAssetImage("images/bg_blue_circle.png"),
        width: 120,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selamat datang pada form Rating Layanan",
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
          const Text(
            "Rating Layanan\nUPA TIK",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildSubheader(),
        ],
      ),
    );
  }

  Widget _buildSubheader() {
    return const Row(
      children: [
        Text(
          "Berikan Ulasan Anda Disini",
          style: TextStyle(
            color: CustomColor.darkBlue,
            fontSize: 12.5,
          ),
        ),
        SizedBox(width: 5),
        Icon(
          Icons.keyboard_double_arrow_down,
          color: CustomColor.darkBlue,
          size: 15,
        ),
      ],
    );
  }

  Widget _buildFormContainer() {
    return Container(
      width: double.maxFinite,
      height: 800,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHideNameSection(),
              const SizedBox(height: 20),
              _buildRatingSection(),
              const SizedBox(height: 20),
              _buildReviewSection(),
              const SizedBox(height: 20),
              _buildImageUploadSection(),
              const SizedBox(height: 35),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHideNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              "Sembunyikan nama anda?",
              style: TextStyle(
                color: CustomColor.fontColorFormRating,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(width: 5),
            Text(
              "(Opsional)",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 10,
                color: CustomColor.fontColorFormRating,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                tristate: false,
                value: hideIdentity,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                side: const BorderSide(width: 1),
                onChanged: (bool? newValue) {
                  setState(() {
                    hideIdentity = newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 5),
            const Text("TIDAK"),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              "Berikan Penilaian Anda",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: CustomColor.fontColorFormRating,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '*',
              style: TextStyle(color: CustomColor.requiredColor),
            ),
          ],
        ),
        const SizedBox(height: 20),
        StarRating(
          size: 50,
          rating: rating,
          color: Colors.orange,
          borderColor: CustomColor.starRatingColor,
          allowHalfRating: true,
          mainAxisAlignment: MainAxisAlignment.start,
          onRatingChanged: (rating) => setState(() {
            this.rating = rating;
          }),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              "Deskripsi Ulasan",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: CustomColor.fontColorFormRating,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '*',
              style: TextStyle(color: CustomColor.requiredColor),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: TextFormField(
            autofocus: true,
            controller: _reviewController,
            scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Ketikkan ulasan anda",
              hintStyle: TextStyle(
                color: Color.fromARGB(100, 0, 0, 0),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              "Upload Gambar Pendukung",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: CustomColor.fontColorFormRating,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '(opsional)',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: CustomColor.fontColorFormRating,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.maxFinite,
          height: 150,
          child: OutlinedButton.icon(
            label: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    children: [
                      _selectedImage != null
                          ? _resizeImage()
                          : const Icon(
                              Icons.file_upload_outlined,
                              size: 50,
                              color: CustomColor.fontColorFormRating,
                            ),
                      Text(
                        _selectedImage != null ? imageName : "Upload File",
                        style: const TextStyle(
                          color: CustomColor.fontColorFormRating,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            style: OutlinedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onPressed: _pickImageFromGallery,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.maxFinite,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _submitRating,
        label: const Text(
          "Kirim",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColor.btnGetStartedColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(35)),
          ),
        ),
      ),
    );
  }

  void _submitRating() async {
    if (rating == 0 || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please provide both a rating and a review")));
      return;
    }

    try {
      await sendRatingData(
        hideIdentity: hideIdentity!,
        rating: rating,
        review: _reviewController.text,
        filePath: _selectedImage?.path,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully')),
      );

      // Clear the form or navigate away as needed
      setState(() {
        hideIdentity = false;
        rating = 0;
        _reviewController.clear();
        _selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
      );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
        imageName = returnedImage.name;
      });
    }
  }

  ClipRRect _resizeImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        _selectedImage!,
        width: 150,
        height: 100,
        fit: BoxFit.fill,
        alignment: Alignment.center,
      ),
    );
  }

  Future<bool> sendRatingData({
    required bool hideIdentity,
    required double rating,
    required String review,
    String? filePath,
  }) async {
    var url = Uri.parse('http://10.0.2.2/wicara/backend/api/mobile/simpan_ulasan_app.php');
    var request = http.MultipartRequest('POST', url);
    
    // Setting fields as strings similar to the second code style
    request.fields['hideIdentity'] = hideIdentity ? '1' : '0';
    request.fields['rating'] = rating.toInt().toString();
    request.fields['review'] = review;

    if (filePath != null) {
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      print('Response: $respStr');
      var jsonResponse = json.decode(respStr);
      // Checking success based on server response
      return jsonResponse['status'] == 'success';
    } else {
      print('Error: ${response.statusCode}');
      return false; // Return false if an error occurs
    }
  }
}
