import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController itsNumberController;
  late final TextEditingController passwordController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    itsNumberController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    itsNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBlocFunc, AuthBlocState>(
      listener: (context, state) {
        //TODO: Handle errors or success navigation here if needed
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple[50]!, Colors.white],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. App Header / Brand
                    Icon(
                      Icons.diversity_3,
                      size: 80,
                      color: Colors.purple[800],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "BGK Ladies",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[900],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 2. Welcome Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // const SizedBox(height: 8),
                          // Text(
                          //   "Login to manage your community",
                          //   style: TextStyle(color: Colors.grey[600]),
                          // ),
                          const SizedBox(height: 30),

                          // ITS Number Input
                          TextField(
                            controller: itsNumberController,
                            keyboardType: TextInputType.number,
                            maxLength: 8,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.badge_outlined,
                                color: Colors.purple,
                              ),
                              hintText: 'Enter your ITS number',
                              filled: true,
                              fillColor: Colors.purple[50]?.withAlpha(200),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Input
                          TextField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.purple,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                              ),
                              hintText: 'Enter your password',
                              filled: true,
                              fillColor: Colors.purple[50]?.withAlpha(200),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      final its = itsNumberController.text;
                                      if (its.length != 8) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "ITS number must be 8 digits",
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      context.read<AuthBlocFunc>().add(
                                        AuthBlocEventLogIn(
                                          itsNumber: int.parse(its),
                                          password: passwordController.text,
                                        ),
                                      );
                                    },
                              child: state.isLoading
                                  ? Center(child: buildLoadingDialog(context))
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 3. Navigation to Register
                    // RichText(
                    //   text: TextSpan(
                    //     style: const TextStyle(
                    //       color: Colors.black54,
                    //       fontSize: 15,
                    //     ),
                    //     children: [
                    //       const TextSpan(text: "Don't have an account? "),
                    //       TextSpan(
                    //         text: "Register here",
                    //         style: const TextStyle(
                    //           color: Colors.purple,
                    //           fontWeight: FontWeight.bold,
                    //           decoration: TextDecoration.underline,
                    //         ),
                    //         recognizer: TapGestureRecognizer()
                    //           ..onTap = () {
                    //             context.read<AuthBlocFunc>().add(
                    //               const AuthBlocEventNavigateToRegister(),
                    //             );
                    //           },
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
