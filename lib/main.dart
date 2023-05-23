import 'package:flutter/material.dart';
import 'package:snake/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'snake-game-5f4f0',
    options: const FirebaseOptions(
      apiKey: "AIzaSyA3sVxezcDuxTtUE0CMpYZG2JqD-gnCh9M",
      authDomain: "snake-game-5f4f0.firebaseapp.com",
      projectId: "snake-game-5f4f0",
      storageBucket: "snake-game-5f4f0.appspot.com",
      messagingSenderId: "964097324245",
      appId: "1:964097324245:web:338bbb0c899fd97ff85e5c")
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(brightness: Brightness.dark),
        home: HomePage());
  }
}
