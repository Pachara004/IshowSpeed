import 'package:flutter/material.dart';
import 'package:ishowspeed/pages/Rider/profilerider.dart';

class RiderHomePage extends StatefulWidget {
  @override
  _RiderHomePageState createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  int _selectedIndex = 0; // ตัวแปรสำหรับติดตาม index ของ BottomNavigationBar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF890E1C),
      body: _selectedIndex == 0 ? _buildOrderList() : ProfileRiderPage(), // แสดงหน้า OrderList หรือ ProfileRiderPage ตาม index

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

  Widget _buildOrderList() {
    return Column(
      children: [
        Expanded(
          child: Container(
            height: 100.0, // ปรับความสูง
            width: 400.0, // ปรับความกว้างถ้าต้องการ
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 70.0), // เพิ่ม margin ด้านข้าง
            decoration: const BoxDecoration(
              color: Color(0xFFFFC809),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Order List',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OrderCard(context: context), // ส่ง context เข้าไป
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget OrderCard({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF890E1C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset('assets/images/red_shirt.png', width: 90, height: 90),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'name : IShowSpeed Shirt',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Shipper : Thorkell',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'recipient : Tawan',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 35),
                  ],
                ),
              ),
              ElevatedButton(
                child: Text('Accept', style: TextStyle(fontSize: 15)),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xFFFFC809),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => _productDetailDialog(context), // ใช้ฟังก์ชันที่สร้าง Dialog
              );
            },
            child: const Text(
              'Click for detail',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 17, 0),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productDetailDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 600,
        height: 600,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF890E1C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Product Name : IShowSpeed Shirt',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const SizedBox(height: 10),
            Center(
              child: Image.asset('assets/images/red_shirt.png', height: 150),
            ),
            const SizedBox(height: 10),
            const Text(
              'Product Details:',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const SizedBox(height: 5),
            const Text(
              'Cotton clothing weighs 0.16 kilograms.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Text(
              'Number of products: 2',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Text(
              'Shipping address: Big saolao',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Text(
              'Shipper: Thorkell',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Text(
              'Recipient name: Mr. Tawan Gamer',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Text(
              'Recipient\'s phone number: 012345678',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                child: Text('Accept', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  // เพิ่ม logic สำหรับ accept ที่นี่
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFC809),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
