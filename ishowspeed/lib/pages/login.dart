import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ishowspeed/pages/register.dart';
import 'package:ishowspeed/pages/User/userhome.dart';
import 'package:ishowspeed/pages/Rider/riderhome.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
bool _isObscure = true;
Future<void> _loginUser(String input, String password) async {
  try {
    bool isPhoneNumber = RegExp(r'^[0-9]+$').hasMatch(input);
    
    QuerySnapshot userQuery;

    if (isPhoneNumber) {
      // ใช้เบอร์โทรในการเข้าสู่ระบบ
      userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: input)
          .where('password', isEqualTo: password)
          .get();
    } else {
      // ใช้อีเมลในการเข้าสู่ระบบ
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: input, password: password);

      // ใช้อีเมลในการค้นหาใน Firestore
      userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: input)
          .where('password', isEqualTo: password)
          .get();
    }

    if (userQuery.docs.isNotEmpty) {
      final userType = userQuery.docs.first['userType'];

      // นำทางไปยังหน้าที่เหมาะสม
      if (userType == 'User') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserHomePage()),
        );
      } else if (userType == 'Rider') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RiderHomePage()),
        );
      }
      print('User: $userQuery');
      print('User: ${userQuery.docs.first.data()}');
      print('User Query Count: ${userQuery.docs.length}');
      print('User Type: $userType');
    } else {
      _showErrorDialog('Invalid phone/email or password');
    }
  } on FirebaseAuthException catch (e) {
    print('Firebase Auth Error Code: ${e.code}'); // แสดงรหัสข้อผิดพลาด
    if (e.code == 'user-not-found') {
      // อีเมลผิด
      _showErrorDialog('Email Is Wrong!');
    } else if (e.code == 'wrong-password') {
      // รหัสผ่านผิด
      _showErrorDialog('You Forgot your Password? Or Not, Dumb ass!!!');
    } else {
      _showErrorDialog('Something went wrong. Please try again.');
    }
  } catch (e) {
    _showErrorDialog('Input the data, damn it!');
  }
}



void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // ปรับขอบโค้งมน
      ),
      title: Row(
        children: [
          Icon(Icons.error, color: Colors.red), // เพิ่มไอคอน Error สีแดง
          SizedBox(width: 10), // เพิ่มระยะห่างระหว่างไอคอนกับข้อความ
          Text(
            'Error',
            style: TextStyle(
              color: Colors.red, // เปลี่ยนสีข้อความเป็นสีแดง
              fontSize: 24, // ปรับขนาดฟอนต์
              fontWeight: FontWeight.bold, // ตัวหนา
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 18, // ปรับขนาดฟอนต์ข้อความเนื้อหา
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.red, // ปรับสีพื้นหลังของปุ่ม
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // ปรับระยะขอบในปุ่ม
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // ขอบปุ่มโค้งมน
            ),
          ),
          child: Text(
            'OK',
            style: TextStyle(
              color: Colors.white, // เปลี่ยนสีข้อความเป็นสีขาว
              fontSize: 16, // ปรับขนาดฟอนต์
              fontWeight: FontWeight.bold, // ตัวหนา
            ),
          ),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890E1C), // สีของ AppBar
      ),
      backgroundColor: const Color(0xFF890E1C), // สีพื้นหลังของ Scaffold
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 100),
              Image.asset(
                'assets/images/logo.png', // Path ของไฟล์ logo.png
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 80),
              // ช่องกรอก Email
              TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(
                  color: Colors.grey[700], // สีของ label ให้ออกแนว modern
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.grey[100], // สีพื้นหลังที่นุ่มสบายตา
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.blueAccent, // สีของไอคอน
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25), // เพิ่มความโค้งมน
                  borderSide: BorderSide.none, // เอาเส้นขอบออกให้ดูสะอาดตา
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Colors.blueAccent, // สีขอบเมื่อโฟกัส
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87, // สีตัวอักษรเมื่อพิมพ์
              ),
            ),
              const SizedBox(height: 16),
              // ช่องกรอก Password
              TextField(
  controller: passwordController,
  decoration: InputDecoration(
    labelText: "Password",
    labelStyle: TextStyle(
      color: Colors.grey[700], // สีของ label แนวโมเดิร์น
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    filled: true,
    fillColor: Colors.grey[100], // สีพื้นหลังที่นุ่มเหมือนช่อง Email
    prefixIcon: Icon(
      Icons.lock,
      color: Colors.blueAccent, // สีของไอคอน Password
    ),
    suffixIcon: IconButton(
      icon: Icon(
        _isObscure ? Icons.visibility : Icons.visibility_off, // สลับไอคอน
        color: Colors.grey[700], // สีของไอคอน
      ),
      onPressed: () {
        setState(() {
          _isObscure = !_isObscure; // สลับการแสดงและซ่อนรหัสผ่าน
        });
      },
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25), // เพิ่มความโค้งมนเหมือนช่อง Email
      borderSide: BorderSide.none, // เอาเส้นขอบออกให้ดีไซน์ดูสะอาด
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(
        color: Colors.blueAccent, // สีขอบเมื่อโฟกัส
        width: 2,
      ),
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 16,
      horizontal: 20,
    ),
  ),
  obscureText: _isObscure, // ปกปิดรหัสผ่านหาก _isObscure เป็น true
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black87, // สีตัวอักษรเมื่อพิมพ์
  ),
),
              const SizedBox(height: 20),
              // ปุ่มเข้าสู่ระบบ
              ElevatedButton(
                onPressed: () {
                  _loginUser(emailController.text, passwordController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC809),
                  fixedSize: const Size(350, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ปุ่มไปหน้า Register
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: const Text(
                  "Register Right Now!",
                  style: TextStyle(
                    color: Colors.yellow,
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
