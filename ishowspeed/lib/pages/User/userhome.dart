import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ishowspeed/pages/User/history.dart';
import 'package:ishowspeed/pages/User/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
        print("Current User: ${_currentUser?.email ?? 'No user logged in'}");
      });
    });
  }

  final List<Widget> _pages = [
    UserDashboard(),
    ProfilePage(),
    UserHistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF890E1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF890E1C),
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF890E1C),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 30, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_4, size: 30, color: Colors.white),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 30, color: Colors.white),
            label: 'Shipping History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellowAccent, // สีที่เด่นขึ้นเมื่อเลือก
        unselectedItemColor: Colors.grey[400], // สีที่ดูอ่อนลงเมื่อไม่ได้เลือก
        selectedIconTheme: IconThemeData(size: 35, color: Colors.yellowAccent), // ขนาดและสีไอคอนเมื่อเลือก
        unselectedIconTheme: IconThemeData(size: 30, color: Colors.grey[400]), // ขนาดและสีไอคอนเมื่อไม่ได้เลือก
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold, // น้ำหนักตัวอักษรหนาขึ้นเมื่อเลือก
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal, // น้ำหนักตัวอักษรเบาลงเมื่อไม่ได้เลือก
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF890E1C),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC809),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Center(
                      child: Text(
                        'Product List',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Products you send:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('Product').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(child: Text('No products available.'));
                              }
                              return Column(
                                children: snapshot.data!.docs.map((doc) {
                                  var data = doc.data() as Map<String, dynamic>;
                                  return ProductItem(
                                    context: context,
                                    name: data['productName'],
                                    shipper: data['shipper'] ?? 'Unknown', // ค่าปริยาย
                                    recipient: data['recipientName'] ?? 'Unknown',
                                    imageUrl: data['imageUrl'],
                                    details: data['productDetails'] ?? 'No details available.',
                                    numberOfProducts: data['numberOfProducts'],
                                    shippingAddress: data['shippingAddress'],
                                    recipientPhone: data['recipientPhone'],
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 120),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Products you must receive:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                           // ใช้ StreamBuilder สำหรับผลิตภัณฑ์ที่ต้องรับเช่นเดียวกัน
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('Product').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(child: Text('No products available.'));
                              }

                              return Column(
                                children: snapshot.data!.docs.map((doc) {
                                  var data = doc.data() as Map<String, dynamic>;
                                  return ProductItem(
                                    context: context,
                                    name: data['productName'],
                                    shipper: data['shipper'] ?? 'Unknown', // ค่าปริยาย
                                    recipient: data['recipientName'] ?? 'Unknown',
                                    imageUrl: data['imageUrl'],
                                    details: data['productDetails'] ?? 'No details available.',
                                    numberOfProducts: data['numberOfProducts'],
                                    shippingAddress: data['shippingAddress'],
                                    recipientPhone: data['recipientPhone'],
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                _showAddProductDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC809),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Add Product",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

 // Method for showing the add product dialog
void _showAddProductDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => _buildAddProductDialog(context),
  );
}

// Widget method for building the add product dialog
Widget _buildAddProductDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  String? _productName,
      _productDetails,
      _numberOfProducts,
      _shippingAddress,
      _recipientName,
      _recipientPhone;
  String? _imageUrl; // สำหรับเก็บ URL ของภาพ

  // ตัวแปรสำหรับเลือกภาพ
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile; // สำหรับเก็บภาพที่เลือก

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      try {
        // สร้าง reference ไปยัง Firebase Storage
        final storageRef = FirebaseStorage.instance.ref('product_images/${_imageFile!.name}');
        
        // อัปโหลดภาพ
        await storageRef.putFile(File(_imageFile!.path));

        // รับ URL ของภาพ
        _imageUrl = await storageRef.getDownloadURL();
        print('Image uploaded: $_imageUrl');
      } catch (e) {
        print('Failed to upload image: $e');
      }
    }
  }

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF890E1C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: IconButton(
                      icon: const Icon(Icons.add_a_photo, color: Color(0xFF890E1C), size: 30),
                      onPressed: () async {
                        // เลือกรูปภาพจากอุปกรณ์
                        _imageFile = await _picker.pickImage(source: ImageSource.gallery);
                        if (_imageFile != null) {
                          setState(() {}); // อัปเดต UI เพื่อแสดงรูปที่เลือก
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Add a product photo',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  // แสดงรูปภาพที่เลือก
                  if (_imageFile != null) ...[
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        // แสดงภาพใน dialog ขนาดใหญ่เมื่อกดที่ภาพ
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Image.file(
                                  File(_imageFile!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 300, // หรือกำหนดความสูงตามที่ต้องการ
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8), // มุมมน
                        child: Image.file(
                          File(_imageFile!.path),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildTextField('Product name', (value) => _productName = value),
                  _buildTextField('Product details', (value) => _productDetails = value),
                  _buildTextField('Number of products', (value) => _numberOfProducts = value),
                  _buildTextField('Shipping address', (value) => _shippingAddress = value),
                  _buildTextField('Recipient name', (value) => _recipientName = value),
                  _buildTextField('Recipient\'s phone number', (value) => _recipientPhone = value),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Color(0xFFFFC809),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        
                        // อัปโหลดภาพไปยัง Firebase Storage
                        // รับ user ID ของผู้ใช้ที่เข้าสู่ระบบ
                        User? user = FirebaseAuth.instance.currentUser;
                        String? userId = user?.uid; // userId จะเก็บ uid ของผู้ใช้
                        await _uploadImage();

                        // สร้าง Map สำหรับข้อมูลผลิตภัณฑ์
                        Map<String, dynamic> productData = {
                          'productName': _productName,
                          'productDetails': _productDetails,
                          'numberOfProducts': _numberOfProducts,
                          'shippingAddress': _shippingAddress,
                          'recipientName': _recipientName,
                          'recipientPhone': _recipientPhone,
                          'imageUrl': _imageUrl, // เก็บ URL ของภาพ
                          'userId': userId, // เพิ่ม userID
                        };

                        // บันทึกข้อมูลผลิตภัณฑ์ไปยัง Firestore
                        try {
                          await FirebaseFirestore.instance.collection('Product').add(productData);
                          print('Product added successfully!');
                          Navigator.of(context).pop(); // Close the dialog
                        } catch (e) {
                          print('Failed to add product: $e');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  );
}


  // Method for building a text field
  Widget _buildTextField(String label, Function(String?) onSave) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
        onSaved: onSave,
      ),
    );
  }

  // Method for product items
  Widget ProductItem({
    required BuildContext context, // รับ context
    required String name,
    required String shipper,
    required String recipient,
    required String imageUrl,
    required String details,
    required String numberOfProducts,
    required String shippingAddress,
    required String recipientPhone,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFAB000D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              imageUrl,
              width: 74,
              height: 80,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: $name',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Shipper: $shipper',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Recipient: $recipient',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _showProductDetailDialog(
                  context, // ส่ง context ให้ฟังก์ชันนี้
                  name: name,
                  imageUrl: imageUrl,
                  details: details,
                  numberOfProducts: numberOfProducts,
                  shippingAddress: shippingAddress,
                  shipper: shipper,
                  recipient: recipient,
                  recipientPhone: recipientPhone,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC809),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Detail'),
            ),
          ),
        ],
      ),
    );
  }

  // Method for showing the product detail dialog
  void _showProductDetailDialog(
    BuildContext context, {
    required String name,
    required String imageUrl,
    required String details,
    required String numberOfProducts,
    required String shippingAddress,
    required String shipper,
    required String recipient,
    required String recipientPhone,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF890E1C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Product Name: $name',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Center(
                child: Image.network(
                  imageUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16),
              Text('Product Details: $details',
                  style: const TextStyle(color: Colors.white)),
              Text('Number of products: $numberOfProducts',
                  style: const TextStyle(color: Colors.white)),
              Text('Shipping address: $shippingAddress',
                  style: const TextStyle(color: Colors.white)),
              Text('Shipper: $shipper', style: const TextStyle(color: Colors.white)),
              Text('Recipient name: $recipient',
                  style: const TextStyle(color: Colors.white)),
              Text('Recipient\'s phone number: $recipientPhone',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
