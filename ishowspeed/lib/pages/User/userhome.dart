import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ishowspeed/pages/User/profile.dart'; // Ensure the path is correct

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0; // Index to track the selected tab
  User? _currentUser; // Store the current user

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user; // Update the current user state
      });
    });
  }

  // List of pages corresponding to each tab
  final List<Widget> _pages = [
    UserDashboard(), // User Dashboard with the Product List
    ProfilePage(),   // Profile Page
    Center(child: Text('Shipping History')), // Placeholder for Shipping History Page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF890E1C), // Set background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF890E1C), // Set AppBar color
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex], // Display the selected page

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF890E1C),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.white),
            label: 'Shipping History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Update the selected index
            print('Selected Index: $_selectedIndex'); // Debug print
          });
        },
      ),
    );
  }
}

// UserDashboard widget
class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Align items to the top
        children: [
          const SizedBox(height: 20), // Add top spacing

          // Product List Container
          Container(
            width: 350, // Set width
            color: const Color(0xFFFFC809), // Background color
            padding: const EdgeInsets.symmetric(vertical: 10), // Add vertical spacing
            child: const Center( // Center the text
              child: Text(
                'Product List',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Text color
                ),
              ),
            ),
          ),

          // User ID Container
          Container(
            width: 350, // Set width
            height: 550, // Set height
            color: const Color(0xFFFFC809), // Background color
            child: Center(
              child: Text(
                'User ID: ${user?.uid ?? 'Not logged in'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black, // Text color
                ),
              ),
            ),
          ),

          const SizedBox(height: 20), // Add bottom spacing

          // Add Product Button
          ElevatedButton(
            onPressed: () {
              // Functionality to add product
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC809),
              fixedSize: const Size(350, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Add Product",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
