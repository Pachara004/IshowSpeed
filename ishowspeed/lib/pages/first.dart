import 'package:flutter/material.dart';
import 'package:ishowspeed/pages/login.dart';
import 'package:ishowspeed/pages/register.dart';

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF890E1C), // Set background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const SizedBox(height: 150),
              Image.asset(
                'assets/images/logo.png', // Path to your logo image
                height: 225, // Set the height of the logo
              ),
              const SizedBox(height: 180), // Space between logo and buttons
              
              // Sign In button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC809), // Set button background color
                  fixedSize: Size(350, 50), // Set button width and height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Set corner radius to 15
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.w800, // Set font weight to extra bold
                    fontSize: 24, // Set the font size
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Space between buttons

               // "Never used IShowSpeed? Register Right now!" link
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF717275), // Default text color
                      fontSize: 16,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Never used IShowSpeed? '),
                      TextSpan(
                        text: 'Register ',
                        style: TextStyle(
                          color: Color(0xFF000000), // Color for "Register"
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: 'Right now!'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30), // Space between buttons
            ],
          ),
        ),
      ),
    );
  }
}
