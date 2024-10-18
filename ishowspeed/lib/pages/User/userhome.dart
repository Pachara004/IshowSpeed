import 'dart:developer';
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
  String? _profileImageUrl;
  String? _username;
  String? _phone;

  @override
  void initState() {
    super.initState();

    // ดึงข้อมูลผู้ใช้จาก FirebaseAuth
    log("message");
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        log(user.toString());
        setState(() {
          _currentUser = user;
        });

        // Log ข้อมูลผู้ใช้
        print("User ID: ${_currentUser!.uid}");
        print("Email: ${_currentUser!.email}");
        print("Phone: ${_currentUser!.phoneNumber}");

        // ดึงข้อมูลผู้ใช้จาก Firestore
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        setState(() {
          _profileImageUrl = userDoc.data()?['profileImage'] ??
              ''; // ถ้าไม่มี URL รูปจะเป็นค่าว่าง
          _username = userDoc.data()?['username'] ??
              'Guest'; // ถ้าไม่มี username จะแสดง Guest
          _phone = userDoc.data()?['phone'];
        });

        // Log ข้อมูลโปรไฟล์ (หากมี)
        log(_phone.toString());
        print("Profile Image URL: $_profileImageUrl");
        print("Username: $_username");
      }
    });
  }

  void _fetchUserData() async {
    if (_currentUser != null) {
      // ดึงรูปโปรไฟล์จาก Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      setState(() {
        _profileImageUrl = userDoc.data()?['profileImage'] ??
            ''; // ถ้าไม่มี URL รูปจะเป็นค่าว่าง
        _username = userDoc.data()?['username'] ??
            'Guest'; // ถ้าไม่มี username จะแสดง Guest
      });

      // Log ข้อมูลโปรไฟล์ (หากมี)
      print("Profile Image URL: $_profileImageUrl");
      print("Username: $_username");
    }
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
        actions: [
          // ใช้ Row เพื่อแสดงรูปโปรไฟล์และชื่อผู้ใช้
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text(
                  _username ??
                      'Guest', // ถ้า _username เป็น null ให้แสดง 'Guest'
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16, // ปรับขนาดฟอนต์ตามต้องการ
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 15),
                _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                            _profileImageUrl!), // ใช้เครื่องหมาย ! เพื่อบอกว่าไม่เป็น null แน่นอน
                        radius: 30, // ปรับขนาดรูปโปรไฟล์
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30, // ปรับขนาดเมื่อไม่มีรูป
                        child: Icon(Icons.person,
                            color: Color(0xFF890E1C), size: 30),
                      ),
                const SizedBox(width: 8), // เว้นช่องว่างระหว่างรูปและชื่อ
              ],
            ),
          ),
        ],
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
        selectedIconTheme: const IconThemeData(
            size: 35, color: Colors.yellowAccent), // ขนาดและสีไอคอนเมื่อเลือก
        unselectedIconTheme: IconThemeData(
            size: 30,
            color: Colors.grey[400]), // ขนาดและสีไอคอนเมื่อไม่ได้เลือก
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
            _fetchUserData();
          });
        },
      ),
    );
  }
}

class UserDashboard extends StatefulWidget {
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  User? _currentUser;
  String? _profileImageUrl;
  String? _username;
  String? _phone;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    // ดึงข้อมูลผู้ใช้จาก FirebaseAuth
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        setState(() {
          _currentUser = user;
        });

        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        setState(() {
          _profileImageUrl = userDoc.data()?['profileImage'] ?? '';
          _username = userDoc.data()?['username'] ?? 'Guest';
          _phone = userDoc.data()?['phone'];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(80.0), // ปรับขนาดความสูงตามที่คุณต้องการ
        child: AppBar(
          backgroundColor: const Color(0xFF890E1C),
          title: const Text(''),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor:
                const Color(0xFFFFC809), // สีของแถบที่เลือก (สีเหลือง)
            indicatorWeight: 4.0, // ความหนาของแถบที่เลือก
            labelColor: Colors.white, // สีตัวอักษรของแท็บที่เลือก
            unselectedLabelColor:
                Colors.white70, // สีตัวอักษรของแท็บที่ไม่ได้เลือก
            labelStyle: const TextStyle(
              fontSize: 18, // ขนาดตัวอักษรของแท็บที่เลือก
              fontWeight: FontWeight.bold, // ทำให้ตัวอักษรของแท็บที่เลือกหนา
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16, // ขนาดตัวอักษรของแท็บที่ไม่ได้เลือก
            ),
            tabs: const [
              Tab(
                text: 'Sender',
                iconMargin: EdgeInsets.only(
                    bottom: 6), // เพิ่มระยะห่างระหว่างไอคอนกับข้อความ
              ),
              Tab(
                text: 'Receiver',
                iconMargin: EdgeInsets.only(
                    bottom: 6), // เพิ่มระยะห่างระหว่างไอคอนกับข้อความ
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSenderTab(),
          _buildReceiverTab(),
        ],
      ),
    );
  }

  Widget _buildSenderTab() {
    return Container(
      color: const Color(0xFFFFC809),
      child: Column(
        children: [
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
                    stream: FirebaseFirestore.instance
                        .collection('Product')
                        .where("userId", isEqualTo: _currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No products available.'));
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return ProductItem(
                            context: context,
                            name: data['productName'],
                            shipper: data['shipper'] ?? 'Unknown',
                            recipient: data['recipientName'] ?? 'Unknown',
                            imageUrl: data['imageUrl'],
                            details: data['productDetails'] ??
                                'No details available.',
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                _showAddProductDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAB000D),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
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

  Widget _buildReceiverTab() {
    return Container(
      color: const Color(0xFFFFC809),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Product')
                        .where("recipientPhone", isEqualTo: _phone)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No products available.'));
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return ProductItem(
                            context: context,
                            name: data['productName'],
                            shipper: data['shipper'] ?? 'Unknown',
                            recipient: data['recipientName'] ?? 'Unknown',
                            imageUrl: data['imageUrl'],
                            details: data['productDetails'] ??
                                'No details available.',
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
    );
  }
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

  // ฟังก์ชันสำหรับเลือกวิธีการรับภาพ
  Future<void> _showImageSourceDialog(BuildContext context, StateSetter setState) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF890E1C),
          title: const Text('เลือกรูปภาพ', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('เลือกจากแกลลอรี่', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1800,
                    maxHeight: 1800,
                  );
                  if (image != null) {
                    setState(() => _imageFile = image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('ถ่ายรูป', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1800,
                    maxHeight: 1800,
                  );
                  if (image != null) {
                    setState(() => _imageFile = image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      try {
        final storageRef =
            FirebaseStorage.instance.ref('product_images/${_imageFile!.name}');
        await storageRef.putFile(File(_imageFile!.path));
        _imageUrl = await storageRef.getDownloadURL();
        print('Image uploaded: $_imageUrl');
      } catch (e) {
        print('Failed to upload image: $e');
      }
    }
  }

  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF890E1C),
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
                    icon: const Icon(Icons.add_a_photo,
                        color: Color(0xFF890E1C), size: 30),
                    onPressed: () => _showImageSourceDialog(context, setState),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add a product photo',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                // แสดงรูปภาพที่เลือก
                if (_imageFile != null) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      // แสดงภาพใน dialog ขนาดใหญ่เมื่อกดที่ภาพ
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              padding: const EdgeInsets.all(8),
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
                _buildTextField(
                    'Product name', (value) => _productName = value),
                _buildTextField(
                    'Product details', (value) => _productDetails = value),
                _buildTextField(
                    'Number of products', (value) => _numberOfProducts = value),
                _buildTextField(
                    'Shipping address', (value) => _shippingAddress = value),
                _buildTextField(
                    'Recipient name', (value) => _recipientName = value),
                _buildTextField('Recipient\'s phone number',
                    (value) => _recipientPhone = value),
                const SizedBox(height: 16),
                ElevatedButton(
                  child: const Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFFFC809),
                    minimumSize: const Size(double.infinity, 50),
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
                        await FirebaseFirestore.instance
                            .collection('Product')
                            .add(productData);
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
  });
}

// Method for building a text field
Widget _buildTextField(String label, Function(String?) onSave) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF890E1C),
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
            const SizedBox(height: 16),
            Center(
              child: Image.network(
                imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Text('Product Details: $details',
                style: const TextStyle(color: Colors.white)),
            Text('Number of products: $numberOfProducts',
                style: const TextStyle(color: Colors.white)),
            Text('Shipping address: $shippingAddress',
                style: const TextStyle(color: Colors.white)),
            Text('Shipper: $shipper',
                style: const TextStyle(color: Colors.white)),
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
