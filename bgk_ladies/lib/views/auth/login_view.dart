// ignore: unused_import
import 'dart:developer' as devtools;

import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/repo/auth/auth_exception.dart';
import 'package:bgk_ladies/utilites/dialog/genrric_dialog.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController itsNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  initState() {
    super.initState();
    itsNumberController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  dispose() {
    itsNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBlocFunc, AuthBlocState>(
      listener: (context, state) {
        //TODO: Handle Error's Display
        if (state is AuthBlocStateLoggedOut &&
            state.exception == InvalidCredentialException()) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text("Login failed: Invalid credentials")),
          // );
          GenericDialog.showGenericDialog(
            context: context,
            title: "Login Failed",
            content: "Invalid credentials. Please try again.",
            optionsBuilder: () => {"OK": null},
          );
        } else if (state is AuthBlocStateLoggedOut &&
            state.exception == UserNotFoundException()) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text("Login failed: User not found")),
          // );
          GenericDialog.showGenericDialog(
            context: context,
            title: "Login Failed",
            content: "User not found. Please check your ITS number.",
            optionsBuilder: () => {"OK": null},
          );
        } else if (state is AuthBlocStateLoggedOut && state.exception != null) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text("Login failed: ${state.exception}")),
          // );
          GenericDialog.showGenericDialog(
            context: context,
            title: "Login Failed",
            content: "An error occurred: ${state.exception}",
            optionsBuilder: () => {"OK": null},
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Scaffold(
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
                            SnackBar(
                              content: Text("Please fill in all fields"),
                            ),
                          );
                          return;
                        }
                        if (itsNumberController.text.length != 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("ITS number must be 8 digits"),
                            ),
                          );
                          return;
                        }
                        context.read<AuthBlocFunc>().add(
                          AuthBlocEventLogIn(
                            itsNumber: int.parse(itsNumberController.text),
                            password: passwordController.text,
                          ),
                        );
                        // devtools.log("User:");
                      },
                      child: Text("Login"),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     context.read<AuthBlocFunc>().add(
                    //       const AuthBlocEventNavigateToRegister(),
                    //     );
                    //   },
                    //   child: Text("To Register"),
                    // ),
                  ],
                ),
              ),
            ),
            if (state.isLoading)
              const Opacity(
                opacity: 0.5,
                child: ModalBarrier(dismissible: false, color: Colors.black),
              ),
            if (state.isLoading) Center(child: buildLoadingDialog(context)),
          ],
        );
      },
    );
  }
}
