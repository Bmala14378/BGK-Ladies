// ignore_for_file: unused_import

import 'package:bgk_ladies/bloc/attend/attend_bloc_func.dart';
import 'package:bgk_ladies/bloc/attend/attend_bloc_states.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:bgk_ladies/services/attend/attend_service.dart';
import 'package:bgk_ladies/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final List<MemberModel> myGroupMembers;
  const EventCard({
    super.key,
    required this.event,
    required this.myGroupMembers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          event.eventName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("Tap to view details"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _showEventSummarySheet(context, event, myGroupMembers);
        },
      ),
    );
  }
}

void _showEventSummarySheet(
  BuildContext context,
  EventModel event,
  List<MemberModel> myMembers,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StreamBuilder<List<AttendanceModel>>(
        // Replace with your service call to get attendance for this event
        stream: AttendService().getEventAttendance(eventId: event.eventId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final attendance = snapshot.data!;

          // FILTER: Only look at attendance records for "My Members"
          final myAttendance = attendance
              .where((a) => myMembers.any((m) => m.itsNumber == a.itsNumber))
              .toList();

          final total = myAttendance.length;
          final present = myAttendance
              .where((a) => a.status == StatusEnum.present)
              .length;
          final late = myAttendance
              .where((a) => a.status == StatusEnum.late)
              .length;
          final absent = myAttendance
              .where((a) => a.status == StatusEnum.absent)
              .length;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.eventName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        "Appointed",
                        total.toString(),
                        Colors.blue,
                      ),
                      _buildStatItem(
                        "Present",
                        present.toString(),
                        Colors.green,
                      ),
                      _buildStatItem("Late", late.toString(), Colors.orange),
                      _buildStatItem("Absent", absent.toString(), Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildStatItem(String label, String count, Color color) {
  return Column(
    children: [
      Text(
        count,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}
