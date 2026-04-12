import 'dart:developer' as devtools;

import 'package:bgk_ladies/bloc/appoint/appoint_bloc_event.dart';
import 'package:bgk_ladies/bloc/appoint/appoint_bloc_func.dart';
import 'package:bgk_ladies/bloc/appoint/appoint_bloc_state.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppointView extends StatefulWidget {
  final List<MemberModel> members;

  const AppointView({super.key, required this.members});

  @override
  State<AppointView> createState() => _AppointViewState();
}

class _AppointViewState extends State<AppointView> {
  final Set<String> _selectedMemberITs = {};
  String _serchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredMembers = widget.members.where((member) {
      final query = _serchQuery.toLowerCase();
      return member.name.toLowerCase().contains(query) ||
          member.itsNumber.toLowerCase().contains(query);
    }).toList();

    return BlocBuilder<AppointBloc, AppointBlocState>(
      builder: (context, state) {
        if (state is AppointBlocStateLoading) {
          return const Scaffold(body: LoadingDialog());
        } else if (state is AppointBlocStateError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Appoint Members')),
            body: Center(child: Text(state.errorMessage)),
          );
        } else if (state is AppointBlocStateAppointmentSubmitted) {
          return Scaffold(
            appBar: AppBar(title: const Text('Appoint Members')),
            body: const Center(child: Text('Members appointed successfully!')),
          );
        }

        List<EventModel> activeEvents = [];
        String? selectedEventId;

        if (state is AppointBlocStateInitial) {
          activeEvents = state.activeEvents;
        } else if (state is AppointBlocStateEventSelected) {
          activeEvents = state.activeEvents;
          selectedEventId = state.eventId;
        }
        devtools.log(
          "Active Events: ${activeEvents.map((e) => e.eventName).join(', ')}",
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Appoint Members',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.purple[800],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: selectedEventId,
                  decoration: const InputDecoration(
                    labelText: "Select Event",
                    border: OutlineInputBorder(),
                  ),
                  items: activeEvents.map((event) {
                    return DropdownMenuItem(
                      value: event.eventId,
                      child: Text(event.eventName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<AppointBloc>().add(
                        AppointBlocEventSelectEvent(eventId: value),
                      );
                      setState(() {
                        _selectedMemberITs.clear();
                      });
                    }
                  },
                ),
              ),
              if (state is AppointBlocStateEventSelected) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _serchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Search by name or ITS number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, index) {
                      final member = filteredMembers[index];
                      final isSelected = _selectedMemberITs.contains(
                        member.itsNumber,
                      );

                      return ListTile(
                        title: Text(member.name),
                        subtitle: Text(member.itsNumber),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedMemberITs.add(member.itsNumber);
                              } else {
                                _selectedMemberITs.remove(member.itsNumber);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[800],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                    onPressed: _selectedMemberITs.isEmpty
                        ? null
                        : () {
                            final List<AttendanceModel> selectedAttendance =
                                widget.members
                                    .where(
                                      (m) => _selectedMemberITs.contains(
                                        m.itsNumber,
                                      ),
                                    )
                                    .map(
                                      (m) => AttendanceModel(
                                        itsNumber: m.itsNumber,
                                        name: m.name,
                                        glName: m.glName,
                                        mohalla: m.mohalla,
                                        markaz: m.markaz,
                                        status: StatusEnum.appointed,
                                        dateTime: DateTime.now(),
                                      ),
                                    )
                                    .toList();

                            context.read<AppointBloc>().add(
                              AppointBlocEventSubmitAppointment(
                                eventId: state.eventId,
                                selectedMembers: selectedAttendance,
                              ),
                            );
                          },
                    child: const Text(
                      'Appoint Selected Members',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ] else ...[
                const Expanded(
                  child: Center(
                    child: Text(
                      "Please select an event from the dropdown to continue.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
