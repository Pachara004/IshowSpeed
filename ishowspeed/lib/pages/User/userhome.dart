import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ishowspeed/pages/User/history.dart';
import 'package:ishowspeed/pages/User/profile.dart'; // ตรวจสอบให้แน่ใจว่าเส้นทางถูกต้อง

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0; // ตัวแปรติดตามแท็บที่เลือก
  User? _currentUser; // เก็บผู้ใช้ปัจจุบัน

  @override
  void initState() {
    super.initState();
    // ฟังการเปลี่ยนแปลงสถานะการยืนยันตัวตน
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user; // อัปเดตสถานะผู้ใช้ปัจจุบัน
      });
    });
  }

  // รายการหน้าที่สอดคล้องกับแท็บแต่ละแท็บ
  final List<Widget> _pages = [
    UserDashboard(), // แดชบอร์ดผู้ใช้ที่มีรายการผลิตภัณฑ์
    ProfilePage(), // หน้าโปรไฟล์
  

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF890E1C), // ตั้งค่าสีพื้นหลัง
      appBar: AppBar(
        backgroundColor: const Color(0xFF890E1C), // ตั้งค่าสี AppBar
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex], // แสดงหน้าที่เลือก

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF890E1C),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.white),
            label: 'Shipping History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // อัปเดตดัชนีที่เลือก
            print('Selected Index: $_selectedIndex'); // พิมพ์ข้อมูลเพื่อดีบัก
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
      color: const Color(0xFF890E1C), // Set background color to maroon
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC809), // Yellow background
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
                          ProductItem(
                            name: 'iShowSpeed Shirt',
                            shipper: 'Thorkell',
                            recipient: 'Tawan',
                            imageUrl: 'assets/images/red_shirt.png',
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
                          ProductItem(
                            name: 'iShowSpeed Shirt',
                            shipper: 'Thorkell',
                            recipient: 'Tawan',
                            imageUrl: 'assets/images/black_shirt.png',
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
                // Add product functionality
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

  // ProductItem widget ที่อยู่ภายใน UserDashboard
  Widget ProductItem({
    required String name,
    required String shipper,
    required String recipient,
    required String imageUrl,
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
            padding: const EdgeInsets.all(8.0), // เพิ่ม Padding ที่นี่
            child: Image.asset(
              imageUrl,
              width:74,
              height:80,
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
                // Detail button functionality
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
}
