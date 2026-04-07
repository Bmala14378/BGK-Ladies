// ignore_for_file: unused_import

import 'package:bgk_ladies/firebase_options.dart';
import 'package:bgk_ladies/views/auth/login_view.dart';
import 'package:bgk_ladies/views/auth/register_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BGK Ladies",
      theme: ThemeData(primarySwatch: Colors.purple),
      routes: {
        "/login": (context) => LoginView(),
        "/register": (context) => RegisterView(),
      },
      home: LoginView(),
    ),
  );
}
