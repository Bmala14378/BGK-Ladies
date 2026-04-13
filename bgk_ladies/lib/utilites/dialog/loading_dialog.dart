import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Widget buildLoadingDialog(BuildContext context) {
  return Dialog(
    elevation: 1,
    backgroundColor: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.threeArchedCircle(
            color: Colors.blue,
            size: 50,
          ),
          const SizedBox(width: 16),
          Text("Loading..."),
        ],
      ),
    ),
  );
}
