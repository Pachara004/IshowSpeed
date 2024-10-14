import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ishowspeed/firebase_options.dart';
import 'package:ishowspeed/pages/first.dart';

void main() async {
  // Connect firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //connect fireStore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
 Widget build(BuildContext context) {
    return MaterialApp(title: 'IShowSpeed',
    home: FirstPage(),);
  } 
}
