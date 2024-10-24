import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:ishowspeed/services/storage/geolocator_services.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _gpsController = TextEditingController();
  String _userType = 'User'; // Track user type based on selected tab
  bool _isObscured = true;
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
    _gpsController.dispose();
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
      _showCustomSnackBar('No image selected.', backgroundColor: Colors.red);
    }
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (_profileImage == null) return null; // ตรวจสอบว่าเลือกภาพแล้ว

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(uid) // สร้างโฟลเดอร์โดยใช้ uid
          .child('profile.jpg'); // ตั้งชื่อไฟล์เป็น profile.jpg
      await ref.putFile(_profileImage!);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      _showCustomSnackBar('Failed to upload profile image: $e',
          backgroundColor: Colors.red);
      return null;
    }
  }

  Future<bool> _isPhoneNumberDuplicate(String phone) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      _showCustomSnackBar('Error checking phone number: $e',
          backgroundColor: Colors.red);
      return false;
    }
  }

// ฟังก์ชันเช็คอีเมลซ้ำ
  Future<bool> _isEmailDuplicate(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> _register() async {
    // ตรวจสอบว่ากรอกข้อมูลครบทุกช่อง
    if (_usernameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        (_userType == 'Rider' && _vehicleController.text.isEmpty)) {
      _showCustomSnackBar('Please fill in all fields',
          backgroundColor: Colors.red);

      return;
    }

    // ตรวจสอบว่าผู้ใช้ได้เลือกรูปภาพหรือยัง
    if (_profileImage == null) {
      _showCustomSnackBar('Please select a profile image',
          backgroundColor: Colors.red);
      return;
    }

    // ตรวจสอบว่ากรอกที่อยู่หรือเลือกพิกัดแล้วหรือยัง
    if (_userType == 'User' && _addressController.text.isEmpty) {
      _showCustomSnackBar('Please provide your address or select a location',
          backgroundColor: Colors.red);
      return;
    }

    // ตรวจสอบว่ากรอกทะเบียนรถเฉพาะเมื่อเป็น Rider
    if (_userType == 'Rider' && _vehicleController.text.isEmpty) {
      _showCustomSnackBar('Please add your vehicle registration number',
          backgroundColor: Colors.red);
      return;
    }

    // ตรวจสอบความยาวของเบอร์โทร
    if (_phoneController.text.length != 10) {
      _showCustomSnackBar('Phone number must be 10 digits',
          backgroundColor: Colors.red);
      return;
    }

    // ตรวจสอบว่าเบอร์โทรซ้ำหรือไม่
    bool isDuplicate = await _isPhoneNumberDuplicate(_phoneController.text);
    if (isDuplicate) {
      _showCustomSnackBar('Phone number already registered',
          backgroundColor: Colors.red);
      return;
    }

    // ตรวจสอบว่าอีเมลซ้ำหรือไม่
    bool isDuplicateEmail = await _isEmailDuplicate(_emailController.text);
    if (isDuplicateEmail) {
      _showCustomSnackBar('Email already registered',
          backgroundColor: Colors.red);
      return;
    }

    // ตรวจสอบความถูกต้องของพิกัด GPS
    String latitude = '';
    String longitude = '';

    if (_userType == 'Rider' || _userType == 'User') {
      // หากเป็น Rider ให้ใช้พิกัดปัจจุบัน
      try {
        LatLng _currentLocation = await GeolocatorServices.getCurrentLocation();
        latitude = _currentLocation.latitude.toString();
        longitude = _currentLocation.longitude.toString();
      } catch (e) {
        _showCustomSnackBar('Failed to get current location: $e',
            backgroundColor: Colors.red);
        return;
      }
    } else {
      // สำหรับผู้ใช้ประเภทอื่น ตรวจสอบว่ากรอกพิกัด GPS ถูกต้องหรือไม่
      if (_gpsController.text.isNotEmpty && _gpsController.text.contains(',')) {
        final gpsParts = _gpsController.text.split(',');

        // ตรวจสอบว่ามีทั้ง latitude และ longitude
        if (gpsParts.length == 2) {
          latitude = gpsParts[0].trim();
          longitude = gpsParts[1].trim();
        } else {
          _showCustomSnackBar(
              'Invalid GPS format. Please provide both latitude and longitude.',
              backgroundColor: Colors.red);
          return;
        }
      } else {
        _showCustomSnackBar('Please provide valid GPS coordinates.',
            backgroundColor: Colors.red);
        return;
      }
    }

    // ตรวจสอบว่ารหัสผ่านตรงกันหรือไม่
    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        // สร้างผู้ใช้ใหม่ด้วย Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // รับ uid ของผู้ใช้ที่ถูกสร้าง
        String uid = userCredential.user!.uid;

        // Upload profile image
        String? profileImageUrl = await _uploadProfileImage(uid) ?? '';

        // สร้างเอกสารใหม่ใน Firestore พร้อมข้อมูลผู้ใช้
        await _firestore.collection('users').doc(uid).set({
          'profileImage': profileImageUrl,
          'username': _usernameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'gps': {
            'latitude': latitude,
            'longitude': longitude,
          },
          'address': _addressController.text,
          'vehicle': _userType == 'Rider' ? _vehicleController.text : '',
          'userType': _userType,
        });

        // แสดงข้อความสำเร็จ
        _showCustomSnackBar('Registration Successful',
            backgroundColor: const Color.fromARGB(255, 3, 180, 17));

        // นำทางกลับไปยังหน้าล็อกอินหรือหน้าที่ต้องการ
        Navigator.pop(context);
      } catch (e) {
        _showCustomSnackBar('Registration Failed: $e',
            backgroundColor: const Color.fromARGB(255, 255, 0, 0));
      }
    } else {
      // รหัสผ่านไม่ตรงกัน
      _showCustomSnackBar('Passwords do not match',
          backgroundColor: const Color.fromARGB(255, 255, 0, 0));
    }
  }

  void _showCustomSnackBar(String message,
      {Color? backgroundColor, Color? textColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white), // กำหนดสีข้อความ
        ),
        backgroundColor: backgroundColor ?? Colors.blue, // กำหนดสีพื้นหลัง
        duration: const Duration(seconds: 3), // ระยะเวลาแสดง
        behavior: SnackBarBehavior.floating, // พฤติกรรมการแสดง
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

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
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt,
                          size: 50, color: Colors.white)
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
                          _buildTextField('Username', _usernameController,
                              Icons.account_circle),
                          const SizedBox(height: 16),
                          _buildTextField(
                              'Phone', _phoneController, Icons.phone,
                              inputType: TextInputType.phone),
                          const SizedBox(height: 16),
                          _buildTextField(
                              'Email', _emailController, Icons.email,
                              inputType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildPasswordField('Password', _passwordController),
                          const SizedBox(height: 16),
                          _buildPasswordField('Confirm Password',
                              _confirmPasswordController, _passwordController),
                          const SizedBox(height: 16),
                          _buildTextField(
                              'Address', _addressController, Icons.location_on),
                          const SizedBox(height: 16),
                          _buildLocationPicker(),
                        ],
                      ),
                    ),
                    // Rider Tab
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          _buildTextField('Username', _usernameController,
                              Icons.account_circle),
                          const SizedBox(height: 16),
                          _buildTextField(
                              'Phone', _phoneController, Icons.phone,
                              inputType: TextInputType.phone),
                          const SizedBox(height: 16),
                          _buildTextField(
                              'Email', _emailController, Icons.email,
                              inputType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildPasswordField('Password', _passwordController),
                          const SizedBox(height: 16),
                          _buildPasswordField('Confirm Password',
                              _confirmPasswordController, _passwordController),
                          const SizedBox(height: 16),
                          _buildTextField('Vehicle Registration Number',
                              _vehicleController, Icons.directions_car),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isKeyboardVisible)
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
  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType inputType = TextInputType.text, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword, // ถ้าเป็นรหัสผ่านให้ซ่อนตัวอักษร
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[700], // สีของ label ที่ดูนุ่มนวล
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.grey[100], // สีพื้นหลังที่อ่อนนุ่ม
        prefixIcon: Icon(
          icon,
          color: Colors.blueAccent, // สีของไอคอนที่ดูทันสมัย
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25), // ขอบที่โค้งมนมากขึ้น
          borderSide: BorderSide.none, // เอาขอบออก
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: Colors.blueAccent, // สีขอบเมื่อโฟกัส
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      keyboardType: inputType,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black87, // สีตัวอักษรเมื่อพิมพ์
      ),
      onChanged: (value) {
        // ตรวจสอบถ้าเป็นฟิลด์รหัสผ่าน ห้ามกด spacebar
        if (isPassword && value.contains(' ')) {
          controller.text = value.replaceAll(' ', ''); // ลบช่องว่างออก
          controller.selection = TextSelection.fromPosition(
            TextPosition(
                offset: controller.text.length), // ตั้งตำแหน่งเคอร์เซอร์ใหม่
          );
        }
        // ถ้าไม่ใช่รหัสผ่าน ห้ามกด spacebar
        if (!isPassword && value.contains(' ')) {
          controller.text = value.replaceAll(' ', ''); // ลบช่องว่างออก
          controller.selection = TextSelection.fromPosition(
            TextPosition(
                offset: controller.text.length), // ตั้งตำแหน่งเคอร์เซอร์ใหม่
          );
        }
      },

      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your $label';
        }
        // ตรวจสอบความยาวของเบอร์โทร
        if (label == 'Phone' && value.length != 10) {
          return 'Phone number must be 10 digits';
        }
        // ตรวจสอบรูปแบบอีเมล
        if (label == 'Email') {
          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegExp.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        // ตรวจสอบรหัสผ่านและยืนยันรหัสผ่าน
        if (label == 'Password' || label == 'Confirm Password') {
          // ห้ามมีช่องว่างในรหัสผ่าน
          if (value.contains(' ')) {
            return 'Password cannot contain spaces';
          }
          // ตรวจสอบความยาวของรหัสผ่าน (อย่างน้อย 6 ตัวอักษร)
          if (value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      [TextEditingController? matchingController]) {
    return TextFormField(
      controller: controller,
      obscureText: _isObscured,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.blueAccent,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility : Icons.visibility_off,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      onChanged: (value) {
        if (value.contains(' ')) {
          // ลบช่องว่างออกจากข้อความ
          controller.text = value.replaceAll(' ', '');
          // ตั้งตำแหน่งเคอร์เซอร์ไปที่ท้ายข้อความ
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your password';
        } else if (value.contains(' ')) {
          return 'Password cannot contain spaces';
        } else if (matchingController != null &&
            value != matchingController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildLocationPicker() {
    return InkWell(
      onTap: () async {
        final selectedLocation = await _showMapDialog(context);
        if (selectedLocation != null) {
          setState(() {
            _gpsController.text =
                '${selectedLocation.latitude}, ${selectedLocation.longitude}';
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.blueAccent, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _gpsController.text.isEmpty
                        ? 'Select Location'
                        : 'Selected:',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_gpsController.text.isNotEmpty)
                    Text(
                      _gpsController.text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.location_on,
              color: Colors.blueAccent,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<LatLng?> _showMapDialog(BuildContext context) async {
    ValueNotifier<LatLng?> selectedLocationNotifier =
        ValueNotifier<LatLng?>(null);
    ValueNotifier<bool> isMapLoaded = ValueNotifier<bool>(false);
    ValueNotifier<LocationData?> currentLocationNotifier =
        ValueNotifier<LocationData?>(null);

    LatLng _currentLocation =
        await GeolocatorServices.getCurrentLocation(); // เก็บตำแหน่งปัจจุบัน

    return showDialog<LatLng>(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด dialog โดยการกดพื้นหลัง
      builder: (context) {
        return AlertDialog(
          title: const Text('Selected Your Tee Yuu'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Stack(
              children: [
                FutureBuilder<void>(
                  future: Future.delayed(const Duration(
                      milliseconds: 100)), // รอให้ dialog แสดงก่อน
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ValueListenableBuilder<LatLng?>(
                        valueListenable: selectedLocationNotifier,
                        builder: (context, selectedLocation, _) {
                          return FlutterMap(
                            options: MapOptions(
                              initialCenter: _currentLocation,
                              initialZoom: 15.0,
                              minZoom: 5.0,
                              maxZoom: 18.0,
                              onTap: (_, point) {
                                selectedLocationNotifier.value = point;
                              },
                              onMapReady: () {
                                isMapLoaded.value = true;
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: const ['a', 'b', 'c'],
                              ),
                              MarkerLayer(
                                markers: [
                                  if (selectedLocation != null)
                                    Marker(
                                      point: selectedLocation,
                                      child: const Icon(
                                        Icons.place,
                                        color: Colors.blue,
                                        size: 40,
                                      ),
                                    ),
                                  if (selectedLocation == null)
                                    Marker(
                                      point: _currentLocation,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    }
                    return Container(
                      color: Colors.white,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'กำลังโหลดแผนที่...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isMapLoaded,
              builder: (context, loaded, _) {
                return TextButton(
                  onPressed: loaded
                      ? () {
                          final location = selectedLocationNotifier.value;
                          if (location != null) {
                            Navigator.of(context).pop(location);
                          } else {
                            Navigator.of(context).pop();
                          }
                        }
                      : null,
                  child: const Text('เลือก'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
