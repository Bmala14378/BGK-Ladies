import 'package:bgk_ladies/themes.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   padding: const EdgeInsets.all(15),
    //   decoration: BoxDecoration(
    //     color: Colors.purple.withAlpha(20),
    //     borderRadius: BorderRadius.circular(15),
    //     border: Border.all(color: Colors.purple.withAlpha(50)),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.purple.withAlpha(20),
    //         offset: const Offset(0, 5),
    //       ),
    //     ],
    //   ),
    //   child: Column(
    //     children: [
    //       Icon(icon, color: Colors.purple),
    //       const SizedBox(height: 5),
    //       Text(
    //         value,
    //         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //       ),
    //       Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    //     ],
    //   ),
    // );
    return Card(
      elevation: 2,
      color: AppTheme.primaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
