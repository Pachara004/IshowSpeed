import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  User? currentUser = FirebaseAuth.instance.currentUser;
  
  if (currentUser != null) {
    // Refresh the user to get the latest information from Firebase
    await currentUser.reload();
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser; // Update with fresh data
    });
    print("Current user UID: ${currentUser!.uid}");
  } else {
    print("No user is logged in.");
  }
}

  @override
  Widget build(BuildContext context) {
    // StreamBuilder to listen for authentication state changes
    return StreamBuilder<User?>(
      // stream: FirebaseAuth.instance.authStateChanges(),
      stream: FirebaseAuth.instance.idTokenChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching authentication status'));
        }
        if (!snapshot.hasData) {
          return _buildLoggedOutUI();
        }

        currentUser = snapshot.data;
        String uid = currentUser!.uid;

        return Scaffold(
          backgroundColor: const Color(0xFF890E1C),
          appBar: AppBar(
            title: const Center(
              child: Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            backgroundColor: const Color(0xFFFFC809),
            automaticallyImplyLeading: false,
          ),
          body: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching profile data'));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('User does not exist'));
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;
              String profileImageUrl = userData['profileImage'] ?? '';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC809),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : const AssetImage('assets/images/default_profile.png')
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${userData['username'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Email: ${userData['email'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField('Phone: ${userData['phone'] ?? 'N/A'}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _logout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoggedOutUI() {
    return Scaffold(
      backgroundColor: const Color(0xFF890E1C),
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        backgroundColor: const Color(0xFFFFC809),
        automaticallyImplyLeading: false,
      ),
      body: const Center(child: Text('User is not logged in')),
    );
  }

  Widget _buildProfileField(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      // Check for internet connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No internet connection')),
        );
        return;
      }

      await FirebaseAuth.instance.signOut();
      await Future.delayed(Duration(seconds: 3));
      print('User logged out successfully');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: $e')),
      );
    }
  }
}
