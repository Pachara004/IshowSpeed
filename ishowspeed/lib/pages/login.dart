import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ishowspeed/pages/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Controller สำหรับ Email และ Password
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // ฟังก์ชันสำหรับ Login
  Future<void> _loginUser(String email, String password) async {
    try {
      // เข้าสู่ระบบด้วย Email และ Password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ดึงข้อมูลผู้ใช้จาก Firestore หลังจาก Login สำเร็จ
      DocumentSnapshot userData = await _firestore.collection('users')
        .doc(userCredential.user?.uid)
        .get();

      // แสดงข้อมูลผู้ใช้
      print("User Data: ${userData.data()}");

      // นำไปยังหน้า Home หรือหน้าถัดไป
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // ถ้าเกิด Error
      print("Error: $e");
      _showErrorDialog("Login Failed", e.toString());
    }
  }

  // ฟังก์ชันแสดง Dialog เมื่อเกิดข้อผิดพลาด
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF890E1C), // สีของ AppBar
    ),
    backgroundColor: const Color(0xFF890E1C), // สีพื้นหลังของ Scaffold
    body: SingleChildScrollView( // เพิ่ม SingleChildScrollView ที่นี่
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // เพิ่มโลโก้ไว้ด้านบน
            const SizedBox(height: 100),
            Image.asset(
              'assets/images/logo.png', // Path ของไฟล์ logo.png
              height: 150, // กำหนดขนาดของโลโก้
            ),
            const SizedBox(height: 20), // เพิ่มช่องว่างระหว่างโลโก้และฟิลด์กรอกข้อมูล
            const Text(
              "Login", // ข้อความด้านล่างปุ่ม Login
              style: TextStyle(
                color: Colors.white, // กำหนดสีของข้อความ
                fontSize: 32, // ขนาดของข้อความ
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 80),
            // ช่องกรอก Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.white, // Set background color to white
                prefixIcon: Icon(Icons.email), // Add Email icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), // Set corner radius
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            // ช่องกรอก Password
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: Colors.white, // Set background color to white
                prefixIcon: Icon(Icons.lock), // Add lock icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), // Set corner radius
                ),
              ),
              obscureText: true, // Hide password
            ),
            const SizedBox(height: 20),
            
            // ปุ่มเข้าสู่ระบบ
            ElevatedButton(
              onPressed: () {
                _loginUser(emailController.text, passwordController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC809), // Set button background color
                fixedSize: Size(350, 50), // Set button width and height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Set corner radius to 15
                ),
              ),
              child: const Text(
                "Login",
                style: TextStyle(
                  fontWeight: FontWeight.w800, // Set font weight to extra bold
                  fontSize: 24, // Set the font size
                  color: Color.fromARGB(255, 0, 0, 0), // Set text color to black
                ),
              ),
            ),
  
            const SizedBox(height: 20),
            // ปุ่มไปหน้า Register
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()), // เรียกหน้า RegisterPage
                );
              },
              child: const Text(
                "Register Right Now!",
                style: TextStyle(
                  color: Colors.yellow, // กำหนดสีของข้อความ
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
