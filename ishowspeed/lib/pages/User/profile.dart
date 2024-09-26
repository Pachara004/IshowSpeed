import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user's UID
    User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF890E1C),
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: const Color(0xFFFFC809),
        ),
        body: const Center(child: Text('User is not logged in')),
      );
    }

    String uid = user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF890E1C),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFFFC809),
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

          // Get user data
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity, // Set width to fill the available space
              decoration: BoxDecoration(
                color: const Color(0xFFFFC809), // Background color
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              padding: const EdgeInsets.all(16.0), // Inner padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display user's profile information in styled containers
                  _buildProfileField('Name: ${userData['username'] ?? 'N/A'}'),
                  _buildProfileField('Email: ${userData['email'] ?? 'N/A'}'),
                  _buildProfileField('Phone: ${userData['phone'] ?? 'N/A'}'),
                  const SizedBox(height: 20), // Space before logout button
                  // Log Out Button
                  ElevatedButton(
                    onPressed: () => _logout(context), // Call the logout method
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Change color if needed
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
  }

  // Helper method to build each profile field with a styled container
  Widget _buildProfileField(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), // Space between fields
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      padding: const EdgeInsets.all(12), // Inner padding
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  // Logout method
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.of(context).pushReplacementNamed('/first'); // Navigate to First.dart
  }
}
