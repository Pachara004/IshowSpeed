import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  String _userType = 'User'; // Track user type based on selected tab

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _profileImage;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }
Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Try to pick an image from the gallery
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    // If an image is picked, update the state
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
    }
  }

Future<String?> _uploadProfileImage(String uid) async {
  if (_profileImage == null) return null;

  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');
    await ref.putFile(_profileImage!);
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to upload profile image: $e')),
    );
    return null;
  }
}

  Future<void> _register() async {
  if (_passwordController.text == _confirmPasswordController.text) {
    try {
      // สร้างผู้ใช้ใหม่ด้วย Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // รับ uid ของผู้ใช้ที่ถูกสร้าง
      String uid = userCredential.user!.uid;

      // Upload profile image
      String? profileImageUrl = await _uploadProfileImage(uid);

      // สร้างเอกสารใหม่ใน Firestore พร้อมข้อมูลผู้ใช้
      await _firestore.collection('users').doc(uid).set({
        'username': _usernameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'address': _addressController.text,
        'vehicle': _userType == 'Rider' ? _vehicleController.text : '',
        'userType': _userType,
      });

      // แสดงข้อความสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful')),
      );

      // นำทางกลับไปยังหน้าล็อกอินหรือหน้าที่ต้องการ
      Navigator.pop(context);

    } catch (e) {
      // จัดการกรณีที่การเขียน Firestore ล้มเหลว
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Failed: $e')),
      );
    }
  } else {
    // รหัสผ่านไม่ตรงกัน
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Passwords do not match')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890E1C),
        title: const Text(''),
      ),
      body: Container(
        color: const Color(0xFF890E1C),
        padding: const EdgeInsets.all(16.0),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const Center(
                child: Text(
                  "Register",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 255, 255, 255),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  onTap: (index) {
                    setState(() {
                      _userType = index == 0 ? 'User' : 'Rider';
                    });
                  },
                  tabs: const [
                    Tab(text: 'User'),
                    Tab(text: 'Rider'),
                  ],
                ),
              ),
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  
                  children: [
                    // User Tab
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          _buildTextField('Username', _usernameController, Icons.account_circle),
                          const SizedBox(height: 16),
                          _buildTextField('Phone', _phoneController, Icons.phone, inputType: TextInputType.phone),
                          const SizedBox(height: 16),
                          _buildTextField('Email', _emailController, Icons.email, inputType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildPasswordField('Password', _passwordController),
                          const SizedBox(height: 16),
                          _buildPasswordField('Confirm Password', _confirmPasswordController, _passwordController),
                          const SizedBox(height: 16),
                          _buildTextField('Address', _addressController, Icons.location_on),
                        ],
                      ),
                    ),
                    // Rider Tab
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          _buildTextField('Username', _usernameController, Icons.account_circle),
                          const SizedBox(height: 16),
                          _buildTextField('Phone', _phoneController, Icons.phone, inputType: TextInputType.phone),
                          const SizedBox(height: 16),
                          _buildTextField('Email', _emailController, Icons.email, inputType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildPasswordField('Password', _passwordController),
                          const SizedBox(height: 16),
                          _buildPasswordField('Confirm Password', _confirmPasswordController, _passwordController),
                          const SizedBox(height: 16),
                          _buildTextField('Vehicle Registration Number', _vehicleController, Icons.directions_car),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC809),
                    fixedSize: const Size(350, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Text field with label and icon
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      keyboardType: inputType,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  // Password field with validation for matching
  Widget _buildPasswordField(String label, TextEditingController controller, [TextEditingController? matchingController]) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your password';
        } else if (matchingController != null && value != matchingController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
