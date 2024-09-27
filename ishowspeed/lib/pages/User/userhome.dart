import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ishowspeed/pages/User/history.dart';
import 'package:ishowspeed/pages/User/profile.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  final List<Widget> _pages = [
    UserDashboard(),
    ProfilePage(),
    UserHistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF890E1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF890E1C),
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex],
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
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF890E1C),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC809),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Center(
                      child: Text(
                        'Product List',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Products you send:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          ProductItem(
                            context: context, // ส่ง context ที่นี่
                            name: 'iShowSpeed Shirt',
                            shipper: 'Thorkell',
                            recipient: 'Tawan',
                            imageUrl: 'assets/images/red_shirt.png',
                            details: 'Cotton clothing weighs 0.16 kilograms.',
                            numberOfProducts: '2',
                            shippingAddress: 'Big saolio',
                            recipientPhone: '0123456789',
                          ),
                          const SizedBox(height: 120),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Products you must receive:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          ProductItem(
                            context: context,
                            name: 'iShowSpeed Shirt',
                            shipper: 'Thorkell',
                            recipient: 'Tawan',
                            imageUrl: 'assets/images/black_shirt.png',
                            details: 'Cotton clothing weighs 0.16 kilograms.',
                            numberOfProducts: '1',
                            shippingAddress: 'Small saolio',
                            recipientPhone: '9876543210',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                _showAddProductDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC809),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Add Product",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method for showing the add product dialog
  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildAddProductDialog(context),
    );
  }

  // Widget method for building the add product dialog
  Widget _buildAddProductDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String? _productName,
        _productDetails,
        _numberOfProducts,
        _shippingAddress,
        _recipientName,
        _recipientPhone;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF890E1C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.add_a_photo,
                      color: Color(0xFF890E1C), size: 30),
                ),
                SizedBox(height: 16),
                Text(
                  'Add a product photo',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 16),
                _buildTextField(
                    'Product name', (value) => _productName = value),
                _buildTextField(
                    'Product details', (value) => _productDetails = value),
                _buildTextField(
                    'Number of products', (value) => _numberOfProducts = value),
                _buildTextField(
                    'Shipping address', (value) => _shippingAddress = value),
                _buildTextField(
                    'Recipient name', (value) => _recipientName = value),
                _buildTextField('Recipient\'s phone number',
                    (value) => _recipientPhone = value),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Color(0xFFFFC809),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      print('Product Name: $_productName');
                      print('Product Details: $_productDetails');
                      print('Number of Products: $_numberOfProducts');
                      print('Shipping Address: $_shippingAddress');
                      print('Recipient Name: $_recipientName');
                      print('Recipient Phone: $_recipientPhone');
                      Navigator.of(context).pop(); // Close the dialog
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method for building a text field
  Widget _buildTextField(String label, Function(String?) onSave) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
        onSaved: onSave,
      ),
    );
  }

  // Method for product items
  Widget ProductItem({
    required BuildContext context, // รับ context
    required String name,
    required String shipper,
    required String recipient,
    required String imageUrl,
    required String details,
    required String numberOfProducts,
    required String shippingAddress,
    required String recipientPhone,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFAB000D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              imageUrl,
              width: 74,
              height: 80,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: $name',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Shipper: $shipper',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Recipient: $recipient',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _showProductDetailDialog(
                  context, // ส่ง context ให้ฟังก์ชันนี้
                  name: name,
                  imageUrl: imageUrl,
                  details: details,
                  numberOfProducts: numberOfProducts,
                  shippingAddress: shippingAddress,
                  shipper: shipper,
                  recipient: recipient,
                  recipientPhone: recipientPhone,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC809),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Detail'),
            ),
          ),
        ],
      ),
    );
  }

  // Method for showing the product detail dialog
  void _showProductDetailDialog(
    BuildContext context, {
    required String name,
    required String imageUrl,
    required String details,
    required String numberOfProducts,
    required String shippingAddress,
    required String shipper,
    required String recipient,
    required String recipientPhone,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF890E1C),
            borderRadius: BorderRadius.circular(16),
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
                  Expanded(
                    child: Text(
                      'Product Name: $name',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Center(
                child: Image.asset(
                  imageUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16),
              Text('Product Details: $details',
                  style: TextStyle(color: Colors.white)),
              Text('Number of products: $numberOfProducts',
                  style: TextStyle(color: Colors.white)),
              Text('Shipping address: $shippingAddress',
                  style: TextStyle(color: Colors.white)),
              Text('Shipper: $shipper', style: TextStyle(color: Colors.white)),
              Text('Recipient name: $recipient',
                  style: TextStyle(color: Colors.white)),
              Text('Recipient\'s phone number: $recipientPhone',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
