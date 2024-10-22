import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ishowspeed/pages/User/addproduct.dart';
import 'package:ishowspeed/pages/User/detail.dart';
import 'package:ishowspeed/pages/User/history.dart';
import 'package:ishowspeed/pages/User/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ishowspeed/services/storage/geolocator_services.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  User? _currentUser;
  String? _profileImageUrl;
  String? _username;
  String? _phoneNumber;
  List<User> _users = []; // รายชื่อผู้ใช้ทั้งหมด
  User? _selectedUser; // ผู้ใช้ที่เลือก

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
        log("User ID: ${_currentUser!.uid}");
        log("Email: ${_currentUser!.email}");
        log("Phone: ${_currentUser!.phoneNumber}");

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
          _phoneNumber = userDoc.data()?['phone'];
        });

        // Log ข้อมูลโปรไฟล์ (หากมี)
        log(_phoneNumber.toString());
        log("Profile Image URL: $_profileImageUrl");
        log("Username: $_username");
        log("Phone: ${_currentUser!.phoneNumber}");
      }
    });
  }

  void _fetchUserData() async {
    if (_currentUser != null) {
      try {
        // ดึงข้อมูลผู้ใช้จาก Firestore
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _profileImageUrl = userDoc.data()?['profileImage'] ?? '';
            _username = userDoc.data()?['username'] ?? 'Guest';
            _phoneNumber = userDoc.data()?['phone'] ??
                'No Phone Number'; // ดึงหมายเลขโทรศัพท์
          });

          // Log ข้อมูลโปรไฟล์
          log("Profile Image URL: $_profileImageUrl");
          log("Username: $_username");
          log("Phone: $_phoneNumber");
        } else {
          log("User document does not exist.");
        }
      } catch (e) {
        log("Error fetching user data: $e");
      }
    } else {
      log("Current user is null.");
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
  String? _phoneNumber;
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

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
          _phoneNumber = userDoc.data()?['phone'];
        });
      }
    });
  }

  void _fetchUserData() async {
    if (_currentUser != null) {
      try {
        // ดึงข้อมูลผู้ใช้จาก Firestore
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _profileImageUrl = userDoc.data()?['profileImage'] ?? '';
            _username = userDoc.data()?['username'] ?? 'Guest';
            _phoneNumber = userDoc.data()?['phone'] ??
                'No Phone Number'; // ดึงหมายเลขโทรศัพท์
          });

          // Log ข้อมูลโปรไฟล์
          log("Profile Image URL: $_profileImageUrl");
          log("Username: $_username");
          log("Phone: $_phoneNumber");
        } else {
          log("User document does not exist.");
        }
      } catch (e) {
        log("Error fetching user data: $e");
      }
    } else {
      log("Current user is null.");
    }
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
    log(_phoneNumber.toString());
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
                        .where("status", isEqualTo: "waiting")
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
                            sender:
                                data['senderName'] ?? _username ?? 'Unknown',
                            name: data['productName'] ?? 'Unknown',
                            recipient: data['recipientName'] ?? 'Unknown',
                            imageUrl: data['imageUrl'] ?? 'Unknown',
                            details: data['productDetails'] ??
                                'No details available.',
                            recipientPhone: data['recipientPhone'],
                            data: data,
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddProductDialog(senderName: _username ?? 'Unknown');
                  },
                );
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
                        .where("recipientPhone",
                            isEqualTo:
                                _phoneNumber) // ตรวจสอบว่า recipientPhone ตรงกับ _phoneNumber
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
                          log(data.toString());
                          log(_phoneNumber.toString());
                          return ProductItem(
                            context: context,
                            sender: data['senderName'] ?? 'Unknown',
                            name: data['productName'] ?? 'Unknown',
                            recipient: data['recipientName'] ?? 'Unknown',
                            imageUrl: data['imageUrl'] ?? 'Unknown',
                            details: data['productDetails'] ??
                                'No details available.',
                            recipientPhone: data['recipientPhone'],
                            data: data,
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

// Method for building a text field
Widget _buildTextField(String label, Function(String?) onSave) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 0, 0, 0),
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
  required String sender,
  required String recipient,
  required String name,
  required String imageUrl,
  required String details,
  required String recipientPhone,
  required Map<String, dynamic> data,
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
                  'Sender: $sender',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Name: $name',
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
              showDialog(
                context: context,
                builder: (BuildContext context) => ProductDetailDialog(
                  imageUrl: imageUrl,
                  details: details,
                  sender: sender,
                  name: name,
                  recipient: recipient,
                  recipientPhone: recipientPhone,
                  recipientLocationLat: data['recipientLocation']['latitude'],
                  recipientLocationLng: data['recipientLocation']['longitude'],
                ),
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
