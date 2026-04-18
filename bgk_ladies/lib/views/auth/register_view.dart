// ignore: unused_import
import 'dart:developer' as devtools;

import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/user_role_enum.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController itsNumberController;
  late final TextEditingController passwordController;
  UserRoleEnum? _selectedRole;
  MarkazEnum? _selectedMarkaz;
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
      listener: (context, state) {},
      builder: (context, state) {
        context.watch<AuthBlocFunc>();
        UserModel? user;
        if (state is AuthBlocStateNavigatingToRegister) user = state.user;
        if (state is AuthBlocStateError) user = state.currentUser;
        if (state is AuthBlocRegistered) user = state.user;
        return Scaffold(
          body: Stack(
            children: [
              // 1. Background Gradient
              Container(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 60,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_outlined, size: 60),
                        const SizedBox(height: 12),
                        Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Registration Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Personal Details",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),

                              TextField(
                                controller: itsNumberController,
                                keyboardType: TextInputType.number,
                                maxLength: 8,
                                decoration: _buildInputDecoration(
                                  "ITS Number",
                                  Icons.badge_outlined,
                                ),
                              ),
                              const SizedBox(height: 16),

                              TextField(
                                controller: passwordController,
                                obscureText: !_isPasswordVisible,
                                keyboardType: TextInputType.number,
                                decoration:
                                    _buildInputDecoration(
                                      "Password",
                                      Icons.lock_outline,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () => setState(
                                          () => _isPasswordVisible =
                                              !_isPasswordVisible,
                                        ),
                                      ),
                                    ),
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Divider(),
                              ),

                              const Text(
                                "Role & Assignment",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),

                              DropdownButtonFormField<UserRoleEnum>(
                                initialValue: _selectedRole,
                                decoration: _buildInputDecoration(
                                  "Select Role",
                                  Icons.assignment_ind_outlined,
                                ),
                                items: UserRoleEnum.values.map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(role.displayName),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedRole = val),
                              ),

                              if (_selectedRole == UserRoleEnum.onGroundAdmin ||
                                  _selectedRole == UserRoleEnum.superUser) ...[
                                const SizedBox(height: 16),

                                DropdownButtonFormField<MarkazEnum>(
                                  initialValue: _selectedMarkaz,
                                  decoration: _buildInputDecoration(
                                    "Select Markaz",
                                    Icons.location_on_outlined,
                                  ),
                                  items: MarkazEnum.values.map((markaz) {
                                    return DropdownMenuItem(
                                      value: markaz,
                                      child: Text(markaz.name),
                                    );
                                  }).toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedMarkaz = val),
                                ),
                              ],
                              const SizedBox(height: 30),

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: state.isLoading
                                      ? null
                                      : _handleRegister,
                                  child: state.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Register",
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

                        // RichText(
                        //   text: TextSpan(
                        //     style: const TextStyle(
                        //       color: Colors.black54,
                        //       fontSize: 15,
                        //     ),
                        //     children: [
                        //       const TextSpan(text: "Already have an account? "),
                        //       TextSpan(
                        //         text: "Login here",
                        //         style: const TextStyle(
                        //           color: Colors.purple,
                        //           fontWeight: FontWeight.bold,
                        //           decoration: TextDecoration.underline,
                        //         ),
                        //         recognizer: TapGestureRecognizer()
                        //           ..onTap = () {
                        //             context.read<AuthBlocFunc>().add(
                        //               const AuthBlocEventLogOut(),
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

              // 2. NEW: Floating Back Button to Dashboard
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      if (user != null) {
                        context.read<AuthBlocFunc>().add(
                          AuthBlocEventNavigateToDash(user: user),
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(labelText: label, prefixIcon: Icon(icon));
  }

  void _handleRegister() {
    if (itsNumberController.text.length != 8) {
      _showSnackBar("ITS number must be 8 digits");
      return;
    }
    if (_selectedRole == null) {
      _showSnackBar("Please select a role");
      return;
    }

    context.read<AuthBlocFunc>().add(
      AuthBlocEventRegister(
        itsNumber: int.parse(itsNumberController.text),
        password: passwordController.text,
        role: _selectedRole!,
        markaz: _selectedMarkaz,
      ),
    );
    _selectedMarkaz = null;
    _selectedRole = null;
    passwordController.clear();
    itsNumberController.clear();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
