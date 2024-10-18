import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ishowspeed/pages/User/profile.dart';

class UserHistoryPage extends StatefulWidget {
  @override
  _UserHistoryPageState createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> with SingleTickerProviderStateMixin {
  User? _currentUser;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 2, vsync: this); // ใช้ vsync: this
    
    // ฟังการเปลี่ยนแปลงสถานะการยืนยันตัวตน
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // กำจัด _tabController เมื่อปิดหน้า
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // จำนวนแท็บ
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0), 
          child: AppBar(
            backgroundColor: const Color(0xFF890E1C),
            title: const Text(''),
            automaticallyImplyLeading: false,
            bottom: TabBar(
              controller: _tabController, // ใช้ _tabController
              indicatorColor: const Color(0xFFFFC809),
              indicatorWeight: 4.0,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
              ),
              tabs: const [
                Tab(
                  text: 'Sender',
                ),
                Tab(
                  text: 'Receiver',
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController, // ใช้ _tabController
          children: [
            _buildProductList('Products you send', 'red_shirt.png', 'Thorkell', 'Tawan'),
            _buildProductList('The product you received', 'black_shirt.png', 'Thorkell', 'Tawan'),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างรายการสินค้า
  Widget _buildProductList(String title, String imageUrl, String shipper, String recipient) {
    return Container(
      color: const Color(0xFFFFC809), // Yellow background
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
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
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
                          ProductItem(
                            name: 'iShowSpeed Shirt',
                            shipper: shipper,
                            recipient: recipient,
                            imageUrl: 'assets/images/$imageUrl',
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

  // ProductItem widget
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
        crossAxisAlignment: CrossAxisAlignment.start, 
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8), 
              child: GestureDetector(
                onTap: () {
                  // ใส่ฟังก์ชันที่ต้องการเมื่อคลิกที่ข้อความ
                },
                child: const Text(
                  'Click for detail',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 0, 0),
                    decoration: TextDecoration.underline,
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
