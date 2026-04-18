// import 'package:bgk_ladies/bloc/appoint/appoint_bloc_event.dart';
// import 'package:bgk_ladies/bloc/appoint/appoint_bloc_func.dart';
// import 'package:bgk_ladies/bloc/appoint/appoint_bloc_state.dart';
// import 'package:bgk_ladies/enums/status_enum.dart';
// import 'package:bgk_ladies/models/attendance_model.dart';
// import 'package:bgk_ladies/models/event_model.dart';
// import 'package:bgk_ladies/models/member_model.dart';
// import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class AppointView extends StatefulWidget {
//   final List<MemberModel> members;

//   const AppointView({super.key, required this.members});

//   @override
//   State<AppointView> createState() => _AppointViewState();
// }

// class _AppointViewState extends State<AppointView> {
//   final Set<String> _selectedMemberITs = {};
//   String _searchQuery = "";

//   @override
//   void initState() {
//     super.initState();
//     // Fetch active events on load
//     context.read<AppointBloc>().add(const AppointBlocEventFetchActiveEvents());
//   }

//   void _toggleMember(String its) {
//     HapticFeedback.lightImpact();
//     setState(() {
//       if (_selectedMemberITs.contains(its)) {
//         _selectedMemberITs.remove(its);
//       } else {
//         _selectedMemberITs.add(its);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     String? lastLoadedEventId;
//     return BlocConsumer<AppointBloc, AppointBlocState>(
//       // 1. Inside _AppointViewState, add a tracke

//       // 2. Update the BlocConsumer listener logic
//       listener: (context, state) {
//         if (state is AppointBlocStateAppointmentSubmitted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Members appointed successfully!"),
//               backgroundColor: Colors.green,
//             ),
//           );
//           // Clear local tracking after a successful submission
//           setState(() {
//             _selectedMemberITs.clear();
//             lastLoadedEventId = null;
//           });
//         } else if (state is AppointBlocStateError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.errorMessage),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//         // Sync the local Set when an event is selected or the DB updates
//         else if (state is AppointBlocStateEventSelected) {
//           if (lastLoadedEventId != state.eventId) {
//             setState(() {
//               _selectedMemberITs.clear();
//               _selectedMemberITs.addAll(state.appointedItsNumbers);
//               lastLoadedEventId = state.eventId;
//             });
//           }
//         }
//       },
//       builder: (context, state) {
//         // Full screen loading prevents interaction during submission
//         if (state is AppointBlocStateLoading) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text("Appoint Members"),
//               backgroundColor: Colors.purple[800],
//               foregroundColor: Colors.white,
//             ),
//             body: Center(child: buildLoadingDialog(context)),
//           );
//         }

//         // 1. Safely Parse State
//         List<EventModel> activeEvents = [];
//         String? currentEventId;

//         if (state is AppointBlocStateInitial) {
//           activeEvents = state.activeEvents;
//         } else if (state is AppointBlocStateEventSelected) {
//           activeEvents = state.activeEvents;
//           currentEventId = state.eventId;
//         }

//         // 2. DROPDOWN FIX: Ensure the currentEventId actually exists in the list
//         if (currentEventId != null &&
//             !activeEvents.any((e) => e.eventId == currentEventId)) {
//           currentEventId = null;
//         }

//         List<MemberModel> filteredMembers = widget.members.where((m) {
//           final query = _searchQuery.toLowerCase();
//           return m.name.toLowerCase().contains(query) ||
//               m.itsNumber.contains(query);
//         }).toList();

//         return Scaffold(
//           appBar: AppBar(title: const Text("Appoint Members")),
//           bottomNavigationBar: _buildBottomBar(currentEventId),
//           body: _buildBody(activeEvents, currentEventId, filteredMembers),
//         );
//       },
//     );
//   }

//   Widget _buildBody(
//     List<EventModel> activeEvents,
//     String? currentEventId,
//     List<MemberModel> filteredMembers,
//   ) {
//     return CustomScrollView(
//       slivers: [
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(
//                     labelText: "Select Event",
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.event),
//                   ),
//                   items: activeEvents.map((event) {
//                     return DropdownMenuItem(
//                       value: event.eventId,
//                       child: Text(event.eventName),
//                     );
//                   }).toList(),
//                   onChanged: (val) {
//                     if (val != null) {
//                       // MATCHES YOUR BLOC: Select Event
//                       context.read<AppointBloc>().add(
//                         AppointBlocEventSelectEvent(eventId: val),
//                       );
//                     }
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   onChanged: (val) => setState(() => _searchQuery = val),
//                   decoration: InputDecoration(
//                     hintText: "Search members...",
//                     prefixIcon: const Icon(Icons.search),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         if (currentEventId != null)
//           SliverPersistentHeader(
//             pinned: true,
//             delegate: _StickyHeaderDelegate(
//               height: 40,
//               child: Container(
//                 color: Colors.grey[200],
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Showing ${filteredMembers.length} members",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//         // Only show list if an event is selected
//         if (currentEventId != null)
//           SliverList(
//             delegate: SliverChildBuilderDelegate((context, index) {
//               final member = filteredMembers[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 child: CheckboxListTile(
//                   title: Text(
//                     member.name,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     "ITS: ${member.itsNumber} • ${member.markaz.name.toUpperCase()}",
//                   ),
//                   activeColor: Colors.purple[800],
//                   value: _selectedMemberITs.contains(member.itsNumber),
//                   onChanged: (val) => _toggleMember(member.itsNumber),
//                 ),
//               );
//             }, childCount: filteredMembers.length),
//           ),

//         // Empty State if no event selected
//         if (currentEventId == null && activeEvents.isNotEmpty)
//           const SliverFillRemaining(
//             hasScrollBody: false,
//             child: Center(
//               child: Text(
//                 "Please select an event to view members.",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ),

//         // Bottom padding to ensure the last item is never hidden behind the navigation bar
//         const SliverToBoxAdapter(child: SizedBox(height: 80)),
//       ],
//     );
//   }

//   Widget _buildBottomBar(String? currentEventId) {
//     int count = _selectedMemberITs.length;
//     bool canSubmit = count > 0 && currentEventId != null;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(50),
//             blurRadius: 10,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: canSubmit
//             ? () {
//                 final selectedAttendance = widget.members
//                     .where((m) => _selectedMemberITs.contains(m.itsNumber))
//                     .map(
//                       (m) => AttendanceModel(
//                         name: m.name,
//                         itsNumber: m.itsNumber,
//                         glName: m.glName,
//                         mohalla: m.mohalla,
//                         markaz: m.markaz,
//                         status: StatusEnum.appointed,
//                         dateTime: DateTime.now(),
//                       ),
//                     )
//                     .toList();

//                 context.read<AppointBloc>().add(
//                   AppointBlocEventSubmitAppointment(
//                     eventId: currentEventId,
//                     selectedMembers: selectedAttendance,
//                   ),
//                 );
//               }
//             : null,
//         child: Text(count == 0 ? "Select Members" : "Appoint $count Members"),
//       ),
//     );
//   }
// }

// class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final Widget child;
//   final double height;
//   _StickyHeaderDelegate({required this.child, required this.height});

//   @override
//   Widget build(context, shrink, overlaps) => child;
//   @override
//   double get maxExtent => height;
//   @override
//   double get minExtent => height;
//   @override
//   bool shouldRebuild(covariant _StickyHeaderDelegate old) => true;
// }

import 'package:bgk_ladies/bloc/appoint/appoint_bloc_event.dart';
import 'package:bgk_ladies/bloc/appoint/appoint_bloc_func.dart';
import 'package:bgk_ladies/bloc/appoint/appoint_bloc_state.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppointView extends StatefulWidget {
  final List<MemberModel> members;

  const AppointView({super.key, required this.members});

  @override
  State<AppointView> createState() => _AppointViewState();
}

class _AppointViewState extends State<AppointView> {
  final Set<String> _selectedMemberITs = {}; // Total items checked in UI
  final Set<String> _alreadySavedITs = {}; // Items already existing in DB
  String? _lastLoadedEventId;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    context.read<AppointBloc>().add(const AppointBlocEventFetchActiveEvents());
  }

  void _toggleMember(String itsNumber) {
    if (_alreadySavedITs.contains(itsNumber)) {
      return;
    }

    setState(() {
      if (_selectedMemberITs.contains(itsNumber)) {
        _selectedMemberITs.remove(itsNumber);
      } else {
        _selectedMemberITs.add(itsNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final newSelections = _selectedMemberITs
        .where((its) => !_alreadySavedITs.contains(its))
        .toList();
    final int newCount = newSelections.length;
    final bool hasUnsavedChanges = newCount > 0;

    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _showExitDialog(context);
        if (shouldPop && context.mounted) {
          // Manually pop the navigator if the user chose "Leave"
          Navigator.of(context).pop();
        }
      },
      child: BlocConsumer<AppointBloc, AppointBlocState>(
        listener: (context, state) {
          if (state is AppointBlocStateAppointmentSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Members appointed successfully!"),
                backgroundColor: Colors.green,
              ),
            );
            // Sync baseline after successful save
            setState(() {
              _alreadySavedITs.clear();
              _alreadySavedITs.addAll(_selectedMemberITs);
            });
          } else if (state is AppointBlocStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AppointBlocStateEventSelected) {
            if (_lastLoadedEventId != state.eventId) {
              setState(() {
                _selectedMemberITs.clear();
                _alreadySavedITs.clear();
                _selectedMemberITs.addAll(state.appointedItsNumbers);
                _alreadySavedITs.addAll(state.appointedItsNumbers);
                _lastLoadedEventId = state.eventId;
              });
            }
          }
        },
        builder: (context, state) {
          List<EventModel> events = [];
          String? currentEventId;

          if (state is AppointBlocStateInitial) {
            events = state.activeEvents;
          } else if (state is AppointBlocStateEventSelected) {
            events = state.activeEvents;
            currentEventId = state.eventId;
          }

          final filteredMembers = widget.members.where((m) {
            return m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                m.itsNumber.contains(_searchQuery);
          }).toList();

          return Scaffold(
            appBar: AppBar(title: const Text("Appoint Members")),
            body: Column(
              children: [
                // Event Selector
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: currentEventId,
                    decoration: const InputDecoration(
                      labelText: "Select Event",
                      border: OutlineInputBorder(),
                    ),
                    items: events
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.eventId,
                            child: Text(e.eventName),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        context.read<AppointBloc>().add(
                          AppointBlocEventSelectEvent(eventId: val),
                        );
                      }
                    },
                  ),
                ),
                if (currentEventId == null)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Please select an event to start appointing",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search name or ITS...",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        final isSelected = _selectedMemberITs.contains(
                          member.itsNumber,
                        );
                        final isSaved = _alreadySavedITs.contains(
                          member.itsNumber,
                        );

                        return ListTile(
                          onTap: () => _toggleMember(member.itsNumber),
                          leading: CircleAvatar(
                            backgroundColor: isSaved
                                ? Colors.green.withAlpha(10)
                                : (isSelected
                                      ? Colors.blue.withAlpha(10)
                                      : null),
                            child: Icon(
                              isSaved ? Icons.cloud_done : Icons.person,
                              color: isSaved
                                  ? Colors.green
                                  : (isSelected ? Colors.blue : Colors.grey),
                            ),
                          ),
                          enabled: false,
                          title: Text(member.name),
                          subtitle: Text(member.itsNumber),
                          trailing: Checkbox(
                            value: isSelected,
                            activeColor: isSaved ? Colors.green : Colors.blue,
                            onChanged: (_) => _toggleMember(member.itsNumber),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            bottomNavigationBar: _buildBottomBar(context, currentEventId),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, String? currentEventId) {
    if (currentEventId != null) {
      // Logic: Only count members that are selected but NOT in the saved list
      final newSelections = _selectedMemberITs
          .where((its) => !_alreadySavedITs.contains(its))
          .toList();
      final int newCount = newSelections.length;

      // Only allow submission if there is at least one NEW member to save
      final bool canSubmit = newCount > 0;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: canSubmit ? Colors.blue : Colors.grey[300],
          ),
          onPressed: canSubmit
              ? () {
                  final membersToAppoint = widget.members
                      .where((m) => newSelections.contains(m.itsNumber))
                      .map(
                        (m) => AttendanceModel(
                          name: m.name,
                          itsNumber: m.itsNumber,
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
                      eventId: currentEventId,
                      selectedMembers: membersToAppoint,
                    ),
                  );
                }
              : null,
          child: Text(
            newCount == 0
                ? "No New Members Selected"
                : "Appoint $newCount New Members",
            style: TextStyle(
              color: canSubmit ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Unsaved Changes"),
            content: const Text(
              "You have selected new members that haven't been saved. Are you sure you want to leave?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Stay on page
                child: const Text("Stay"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), // Leave page
                child: const Text("Leave"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
