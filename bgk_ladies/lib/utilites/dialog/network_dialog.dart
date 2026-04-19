// ignore_for_file: dead_code

import 'package:bgk_ladies/bloc/network/network_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showNoInternetDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: StatefulBuilder(
          // Added to manage local "loading" state for the button
          builder: (context, setState) {
            bool isRetrying = false;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.red),
                  SizedBox(width: 10),
                  Text("No Connection"),
                ],
              ),
              content: const Text(
                "Please check your internet settings. The app will automatically resume once you are back online.",
              ),
              actions: [
                TextButton(
                  onPressed: isRetrying
                      ? null
                      : () async {
                          setState(() => isRetrying = true);

                          // Trigger the manual check
                          context.read<NetworkBloc>().add(NetworkEventCheck());

                          // Small delay so the user sees the interaction
                          await Future.delayed(const Duration(seconds: 1));

                          if (context.mounted) {
                            setState(() => isRetrying = false);
                          }
                        },
                  child: isRetrying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Retry Now"),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
