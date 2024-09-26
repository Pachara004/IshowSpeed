import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RiderHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลผู้ใช้ที่ล็อกอิน
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rider Home"),
        backgroundColor: const Color(0xFF890E1C), // สี AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Rider Home Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // แสดง uid ของผู้ใช้
            Text(
              'User ID: ${user?.uid ?? 'Not logged in'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // ฟังก์ชันสำหรับ Log Out
                await FirebaseAuth.instance.signOut();
                // นำทางกลับไปยังหน้าล็อกอินหรือหน้าอื่นตามที่ต้องการ
                Navigator.pop(context); // ตัวอย่างการนำทางกลับ
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC809), // สีของปุ่ม
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
