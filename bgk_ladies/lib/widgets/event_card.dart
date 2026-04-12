import 'package:bgk_ladies/models/event_model.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final EventModel event; // Use your EventModel type here
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.calendar_today, color: Colors.white, size: 20),
        ),
        title: Text(
          event.eventName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // subtitle: const Text("Tap to view details or mark attendance"),
        // trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to Attendance or Details screen
        },
      ),
    );
  }
}
