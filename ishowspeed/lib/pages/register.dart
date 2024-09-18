import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController(); // for rider
  String _userType = 'User'; // Default user type

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

Future<void> _register() async {
  if (_formKey.currentState?.validate() ?? false) {
    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email or password cannot be empty.');
      }

      final auth = _auth;
      final firestore = _firestore;
      if (auth == null || firestore == null) {
        throw Exception('Auth or Firestore instance is not initialized.');
      }

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception('User ID is null.');
      }

      print('User registered with UID: $uid'); // Add this line

      final userType = _userType;
      if (userType == 'User') {
        await firestore.collection('users').doc(uid).set({
          'uid': uid,
          'phone': _phoneController.text,
          'name': _usernameController.text,
          'address': _addressController.text,
          'userType': 'User',
        });
      } else if (userType == 'Rider') {
        await firestore.collection('riders').doc(uid).set({
          'uid': uid,
          'phone': _phoneController.text,
          'name': _usernameController.text,
          'vehicle': _vehicleController.text,
          'userType': 'Rider',
        });
      }

      print('User data saved to Firestore'); // Add this line

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Registration successful!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.pushReplacementNamed(context, '/login'); // Navigate to login page
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

    } catch (e) {
      print('Error during registration: $e'); // Add this line
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error: $e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890E1C), // Background color
        title: const Text(''),
      ),
      body: Container(
        color: const Color(0xFF890E1C), // Background color for the body
        padding: const EdgeInsets.all(16.0),
        child: DefaultTabController(
          length: 2, // Number of tabs
          child: Column(
            children: [
              const Center(
                child: Text(
                  "Register", // Text below the button
                  style: TextStyle(
                    color: Colors.white, // Set text color to white
                    fontSize: 32, // Set the font size
                    fontWeight: FontWeight.w800, // Set font weight to extra bold
                  ),
                ),
              ),
              // Container with TabBar decoration
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 255, 255, 255), // Background color of the container
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                  border: Border.all(
                    color: Colors.white, // Border color
                    width: 2, // Border width
                  ),
                ),
                child: TabBar(
                  indicatorColor: Colors.white, // Custom TabBar indicator color
                  labelColor: Colors.white, // Color for selected tab label
                  unselectedLabelColor: Colors.grey, // Color for unselected tab labels
                  onTap: (index) {
                    setState(() {
                      _userType = index == 0 ? 'User' : 'Rider'; // Set userType based on tab
                    });
                  },
                  tabs: const [
                    Tab(text: 'User'),
                    Tab(text: 'Rider'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Content for User tab
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          // Username
                          _buildTextField('Username', _usernameController, Icons.account_circle),
                          const SizedBox(height: 16),
                          // Phone Number
                          _buildTextField('Phone', _phoneController, Icons.phone, inputType: TextInputType.phone),
                          const SizedBox(height: 16),
                          // Email
                          _buildTextField('Email', _emailController, Icons.email, inputType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          // Password
                          _buildPasswordField('Password', _passwordController),
                          const SizedBox(height: 16),
                          // Confirm Password
                          _buildPasswordField('Confirm Password', _confirmPasswordController, _passwordController),
                          const SizedBox(height: 16),
                          // Address Field for User
                          _buildTextField('Address', _addressController, Icons.location_on),
                        ],
                      ),
                    ),
                    // Content for Rider tab
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          // Username
                          _buildTextField('Username', _usernameController, Icons.account_circle),
                          const SizedBox(height: 16),
                          // Phone Number
                          _buildTextField('Phone', _phoneController, Icons.phone, inputType: TextInputType.phone),
                          const SizedBox(height: 16),
                          // Email
                          _buildTextField('Email', _emailController, Icons.email, inputType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          // Password
                          _buildPasswordField('Password', _passwordController),
                          const SizedBox(height: 16),
                          // Confirm Password
                          _buildPasswordField('Confirm Password', _confirmPasswordController, _passwordController),
                          const SizedBox(height: 16),
                          // Vehicle Registration Number Field for Rider
                          _buildTextField('Vehicle Registration Number', _vehicleController, Icons.directions_car),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Register Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC809), // Set button background color
                    fixedSize: const Size(350, 50), // Set button width and height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Set corner radius to 15
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontWeight: FontWeight.w800, // Set font weight to extra bold
                      fontSize: 24, // Set the font size
                      color: Color.fromARGB(255, 0, 0, 0), // Set text color to black
                    ),
                  ),
                ),
              ),
              // Centered text below the button
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a text field
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      keyboardType: inputType,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  // Helper method to create a password field
  Widget _buildPasswordField(String label, TextEditingController controller, [TextEditingController? matchingController]) {
    return TextFormField(
      controller: controller,
      obscureText: true, // Hide text
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your password';
        } else if (matchingController != null && value != matchingController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
