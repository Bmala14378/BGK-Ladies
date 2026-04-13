import 'dart:developer' as devtools;

import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/user_role_enum.dart';
import 'package:bgk_ladies/utilites/dialog/genrric_dialog.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  TextEditingController itsNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List<DropdownMenuItem<String>> roleEntries = UserRoleEnum.values
      .map(
        (role) => DropdownMenuItem<String>(
          value: role.name,
          child: Text(role.displayName),
        ),
      )
      .toList();

  UserRoleEnum? _selectedRole;

  MarkazEnum? _selectedMarkaz;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBlocFunc, AuthBlocState>(
      listener: (context, state) {
        if (state is AuthBlocStateLoggedIn) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Registration successful!")));
          context.read<AuthBlocFunc>().add(
            const AuthBlocEventNavigateToLogin(),
          );
        } else if (state is AuthBlocStateLoggedOut && state.exception != null) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text("Registration failed: ${state.exception}")),
          // );
          GenericDialog.showGenericDialog(
            context: context,
            title: "Registration Failed",
            content: "An error occurred during registration. Please try again.",
            optionsBuilder: () => {"OK": null},
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(title: Text("Register")),
              body: Center(
                child: Column(
                  children: [
                    TextField(
                      controller: itsNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      decoration: InputDecoration(
                        hint: Text("Enter your ITS number"),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    // DropdownMenu(
                    //   dropdownMenuEntries: roleEntries,
                    //   label: Text("Select your role"),
                    //   initialSelection: roleEntries.first.value,
                    //   onSelected: (value) {
                    //     // Handle role selection
                    //   },
                    // ),
                    DropdownButtonFormField(
                      items: roleEntries,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = UserRoleEnum.values.firstWhere(
                            (role) => role.name == value,
                          );
                        });
                      },
                      decoration: InputDecoration(
                        label: Text("Select your role"),
                        border: OutlineInputBorder(),
                        prefix: Icon(Icons.person),
                      ),
                    ),
                    if (_selectedRole == UserRoleEnum.onGroundAdmin)
                      DropdownButtonFormField(
                        items: MarkazEnum.values
                            .map(
                              (markaz) => DropdownMenuItem<String>(
                                value: markaz.name,
                                child: Text(markaz.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMarkaz = MarkazEnum.values.firstWhere(
                              (markaz) => markaz.name == value,
                            );
                          });
                        },
                        decoration: InputDecoration(
                          label: Text("Select your markaz"),
                          border: OutlineInputBorder(),
                          prefix: Icon(Icons.location_on),
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
                        if (_selectedRole == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please select a role")),
                          );
                          return;
                        }
                        if (_selectedRole == UserRoleEnum.onGroundAdmin &&
                            _selectedMarkaz == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please select a markaz")),
                          );
                          return;
                        }
                        if (itsNumberController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please fill all fields")),
                          );
                          return;
                        }
                        if (int.tryParse(itsNumberController.text) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("ITS number must be valid")),
                          );
                          return;
                        }
                        if (_selectedMarkaz != null &&
                            _selectedRole == UserRoleEnum.onGroundAdmin) {
                          devtools.log(
                            "Selected Markaz: ${_selectedMarkaz!.name}",
                          );
                        } else {
                          devtools.log("No Markaz selected");
                          _selectedMarkaz = null;
                        }
                        context.read<AuthBlocFunc>().add(
                          AuthBlocEventRegister(
                            itsNumber: int.parse(itsNumberController.text),
                            password: passwordController.text,
                            role: _selectedRole!,
                            markaz: _selectedMarkaz,
                          ),
                        );
                        _selectedRole = null;
                        _selectedMarkaz = null;
                        itsNumberController.clear();
                        passwordController.clear();
                      },
                      child: Text("Register"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBlocFunc>().add(
                          const AuthBlocEventNavigateToDash(),
                        );
                      },
                      child: Text("Back"),
                    ),
                  ],
                ),
              ),
            ),
            if (state.isLoading)
              const Opacity(
                opacity: 0.8,
                child: ModalBarrier(dismissible: false, color: Colors.black),
              ),
            if (state.isLoading) Center(child: buildLoadingDialog(context)),
          ],
        );
      },
    );
  }
}
