// ignore_for_file: unused_import

import 'package:bgk_ladies/bloc/attend/attend_bloc_func.dart';
import 'package:bgk_ladies/bloc/attend/attend_bloc_states.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/models/member_model.dart';
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
        // subtitle: const Text("Tap to view details"),
        // trailing: const Icon(Icons.chevron_right),
        onTap: () {
          //TODO: Add active event bottom sheet in the DashboardView for quick stats and actions related to the active event
          //showEventActions(context, event, myGroupMembers);
        },
      ),
    );
  }
}

// void _showEventActions(
//   BuildContext context,
//   EventModel event,
//   List<MemberModel> groupMembers,
// ) {
//   // Create a Set of ITS numbers for the current user's group for O(1) lookup
//   final myGroupItsNumbers = groupMembers.map((m) => m.itsNumber).toSet();

//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Pull Handle
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(bottom: 15),
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),

//             Text(
//               event.eventName,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),

//             // --- Stats Section ---
//             BlocBuilder<AttendBloc, AttendBlocState>(
//               builder: (context, state) {
//                 if (state is AttendBlocStateLoaded) {
//                   // Filter: Only show attendance records where the itsNumber
//                   // exists in myGroupItsNumbers AND matches this specific event
//                   final myGroupAttendance = state.attendanceList
//                       .where(
//                         (record) =>
//                             myGroupItsNumbers.contains(record.itsNumber),
//                       )
//                       .toList();

//                   if (myGroupAttendance.isEmpty) {
//                     return _buildEmptyGroupState();
//                   }

//                   // Calculate Statuses
//                   final present = myGroupAttendance
//                       .where((m) => m.status == StatusEnum.present)
//                       .length;
//                   final late = myGroupAttendance
//                       .where((m) => m.status == StatusEnum.late)
//                       .length;
//                   final absent = myGroupAttendance
//                       .where((m) => m.status == StatusEnum.absent)
//                       .length;
//                   final total = myGroupAttendance.length;

//                   return Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: AppTheme.primaryLight.withAlpha(50),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _buildStatsItem(
//                           "Appointed",
//                           total.toString(),
//                           AppTheme.primaryPurple,
//                         ),
//                         _buildStatsItem(
//                           "Present",
//                           present.toString(),
//                           AppTheme.statusPresent,
//                         ),
//                         _buildStatsItem(
//                           "Late",
//                           late.toString(),
//                           AppTheme.statusLate,
//                         ),
//                         _buildStatsItem(
//                           "Absent",
//                           absent.toString(),
//                           AppTheme.statusAbsent,
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//                 return const Center(child: CircularProgressIndicator());
//               },
//             ),

//             const SizedBox(height: 20),
//             const Divider(),

//             // --- Navigation Actions ---
//             ListTile(
//               leading: const Icon(Icons.check_circle_outline),
//               title: const Text("Mark Attendance"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/attend', arguments: event);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.person_add_alt_1_outlined),
//               title: const Text("Appoint Members"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/appoint', arguments: event);
//               },
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// Widget _buildEmptyGroupState() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 30),
//     child: Column(
//       children: [
//         Icon(Icons.group_off_outlined, color: Colors.grey[400], size: 50),
//         const SizedBox(height: 12),
//         const Text(
//           "No members from your group\nare appointed to this event.",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.grey,
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildStatsItem(String label, String value, Color color) {
//   return Column(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Text(
//         value,
//         style: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: color,
//         ),
//       ),
//       Text(
//         label,
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//           color: Colors.grey[700],
//         ),
//       ),
//     ],
//   );
// }
