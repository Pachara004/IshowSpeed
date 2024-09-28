import 'package:flutter/material.dart';

class RiderHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF890E1C),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC809),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Order List',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    OrderCard(context: context), // ส่ง context เข้าไป
                  ],
                ),
              ),
            ),
          ),
          BottomNavigationBar(
            backgroundColor: const Color(0xFF890E1C),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget OrderCard({required BuildContext context}) { // รับ BuildContext
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
              SizedBox(width: 10),
              Expanded(
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
            child: Text(
              'Click for detail',
              style: TextStyle(
                color: const Color.fromARGB(255, 255, 17, 0),
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
            SizedBox(height: 10),
            Text(
              'Product Name : IShowSpeed Shirt',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            SizedBox(height: 10),
            Center(
              child: Image.asset('assets/images/red_shirt.png', height: 150),
            ),
            SizedBox(height: 10),
            Text(
              'Product Details:',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            SizedBox(height: 5),
            Text(
              'Cotton clothing weighs 0.16 kilograms.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Number of products: 2',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Shipping address: Big saolao',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Shipper: Thorkell',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Recipient name: Mr. Tawan Gamer',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Recipient\'s phone number: 012345678',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Spacer(),
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
