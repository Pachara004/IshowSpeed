import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ishowspeed/pages/User/profile.dart';

class UserHistoryPage extends StatefulWidget {
  @override
  _UserHistoryPageState createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserDashboard(),
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
                        'Shipping History',
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
                              'The product you received:',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // จัดตำแหน่งให้ชิดซ้าย
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
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
                  child: const Text('Status'),
                ),
              ),
            ],
          ),
          // เพิ่มข้อความ Click for detail
          Center( // ใช้ Center เพื่อจัดตำแหน่งข้อความให้อยู่ตรงกลาง
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8), // เพิ่ม Padding ให้กับข้อความ
              child: GestureDetector(
                onTap: () {
                  // ใส่ฟังก์ชันที่ต้องการให้เกิดเมื่อคลิกที่ข้อความนี้
                },
                child: const Text(
                  'Click for detail',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 0, 0),
                    decoration: TextDecoration.underline, // ขีดเส้นใต้
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
