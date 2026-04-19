// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/models/user_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBlocFunc, AuthBlocState>(
      listener: (context, state) {
        if (state is AuthBlocStateError && state.exception.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.exception),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        UserModel? user;

        // Grab the user from the state safely
        if (state is AuthBlocStateLoggedIn) user = state.user;
        if (state is AuthBlocStateError) user = state.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(child: Text("User data not found.")),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("My Profile"), elevation: 0),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                _buildProfileItem(
                  Icons.badge,
                  "ITS Number",
                  user.itsNumber.toString(),
                ),
                const Divider(),
                _buildProfileItem(
                  Icons.admin_panel_settings,
                  "Role",
                  user.role.name.toUpperCase(),
                ),
                const Divider(),
                _buildProfileItem(
                  Icons.location_on,
                  "Markaz",
                  user.markaz?.name.toUpperCase() ?? "N/A",
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade50,
                      foregroundColor: Colors.blueGrey.shade900,
                    ),
                    icon: const Icon(Icons.lock_reset),
                    label: const Text("Change Password"),
                    onPressed: () => _showChangePasswordDialog(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // We use a ValueNotifier to handle the spinner locally without triggering
    // the global loading dialog in main.dart
    final isSubmitting = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocListener<AuthBlocFunc, AuthBlocState>(
          listener: (context, state) {
            if (state is AuthBlocStatePasswordChangeSuccess) {
              isSubmitting.value = false;
              Navigator.pop(
                dialogContext,
              ); // Close dialog ONLY on actual success
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password changed successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is AuthBlocStateError) {
              // Stop the spinner so they can try again.
              // The red snackbar is already handled by the main listener at the top of ProfileView!
              isSubmitting.value = false;
            }
          },
          child: ValueListenableBuilder<bool>(
            valueListenable: isSubmitting,
            builder: (context, submitting, child) {
              return AlertDialog(
                title: const Text("Change Password"),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: oldPasswordController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        enabled: !submitting,
                        decoration: const InputDecoration(
                          labelText: "Current Password",
                        ),
                        validator: (val) =>
                            val != null && val.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: newPasswordController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        enabled: !submitting,
                        decoration: const InputDecoration(
                          labelText: "New Password",
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: submitting
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: submitting
                        ? null
                        : () {
                            isSubmitting.value = true; // Start spinner

                            // Dispatch the event
                            context.read<AuthBlocFunc>().add(
                              AuthBlocEventChangePassword(
                                oldPassword: oldPasswordController.text,
                                newPassword: newPasswordController.text,
                              ),
                            );
                          },
                    child: submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Save"),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
