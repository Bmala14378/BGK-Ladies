import 'package:bgk_ladies/themes.dart';
import 'package:flutter/material.dart';

Widget buildEmptyState() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.backgroundGrey,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Column(
      children: [
        Icon(Icons.event_busy, color: Colors.grey, size: 40),
        SizedBox(height: 10),
        Text(
          "No active events at the moment.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
}
