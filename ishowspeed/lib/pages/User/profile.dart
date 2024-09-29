import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ishowspeed/pages/User/editprofile.dart';
import 'package:ishowspeed/pages/login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    checkCurrentUser();
  }

  void checkCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {
        currentUser = FirebaseAuth.instance.currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return LoginPage();
        }

        currentUser = snapshot.data;
        String uid = currentUser!.uid;

        return Scaffold(
          backgroundColor: const Color(0xFF890E1C),
          appBar: AppBar(
            title: Center(
              child: const Text(
                'Profile',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: const Color(0xFFFFC809),
            elevation: 0,
          ),
          body: FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('User data not found'));
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;
              String profileImageUrl = userData['profileImage'] ?? '';

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: const Color(0xFFFFC809),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // จัดข้อความชิดซ้าย
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // จัดข้อความให้อยู่ด้านบนของ Row
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: profileImageUrl.isNotEmpty
                                    ? NetworkImage(profileImageUrl)
                                    : const AssetImage(
                                            'assets/images/default_profile.png')
                                        as ImageProvider,
                              ),
                              const SizedBox(
                                  width:
                                      16), // เพิ่มระยะห่างระหว่างรูปโปรไฟล์กับข้อความ
                              Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // จัดข้อความชิดซ้าย
                                children: [
                                  Text(
                                    userData['username'] ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(
                                      height:
                                          4), // ลดระยะห่างระหว่าง username และ email
                                  Text(
                                    userData['email'] ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                              height:
                                  10), // เพิ่มระยะห่างระหว่าง Row และ Personal Information
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0.0, left: 16.0, right: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Personal Information',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // เชื่อมไปยังหน้า EditProfilePage
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfilePage(),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Edit',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                        _buildInfoRow('Full Name',
                                            userData['username'] ?? 'N/A'),
                                        _buildInfoRow('Phone',
                                            userData['phone'] ?? 'N/A'),
                                        _buildInfoRow('Email',
                                            userData['email'] ?? 'N/A'),
                                        _buildInfoRow('Address',
                                            userData['address'] ?? 'N/A'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 150), // ย้าย SizedBox ไปที่นี่
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20), // เพิ่มระยะห่างก่อนปุ่ม

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Center(
                              // ใช้ Center เพื่อทำให้ปุ่มอยู่ตรงกลาง
                              child: ElevatedButton(
                                onPressed: () => _logout(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                      0xFFFFC809), // สีปุ่มเป็นสีเหลือง
                                  minimumSize: const Size(
                                      80, 50), // ปรับความกว้างของปุ่ม
                                  shadowColor: Colors.black, // สีเงา
                                  elevation: 15, // ความสูงของเงา
                                ),
                                child: const Text(
                                  'Log out',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black), // สีข้อความเป็นสีดำ
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: $e')),
      );
    }
  }
}
