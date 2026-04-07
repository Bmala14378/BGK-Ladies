import 'dart:developer' as devtools;

import 'package:bgk_ladies/constants/routes.dart';
import 'package:bgk_ladies/repo/auth_repo.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController itsNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: itsNumberController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: InputDecoration(
                hint: Text("Enter your its number"),
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hint: Text("Enter your password"),
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (itsNumberController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill in all fields")),
                  );
                  return;
                }
                if (itsNumberController.text.length != 8) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("ITS number must be 8 digits")),
                  );
                  return;
                }
                final user = await AuthRepository().login(
                  int.parse(itsNumberController.text),
                  passwordController.text,
                );
                devtools.log(
                  "User: ${user?.itsNumber}, ${user?.markaz}, ${user?.role}",
                );
                SnackBar(content: Text("Login successful"));
              },
              child: Text("Login"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: Text("To Register"),
            ),
          ],
        ),
      ),
    );
  }
}
