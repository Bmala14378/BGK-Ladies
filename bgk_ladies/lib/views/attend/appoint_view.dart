import 'package:bgk_ladies/bloc/appoint/appoint_bloc_event.dart';
import 'package:bgk_ladies/bloc/appoint/appoint_bloc_func.dart';
import 'package:bgk_ladies/bloc/appoint/appoint_bloc_state.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppointView extends StatefulWidget {
  final List<MemberModel> members;

  const AppointView({super.key, required this.members});

  @override
  State<AppointView> createState() => _AppointViewState();
}

class _AppointViewState extends State<AppointView> {
  final Set<String> _selectedMemberITs = {};
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Fetch active events on load
    context.read<AppointBloc>().add(const AppointBlocEventFetchActiveEvents());
  }

  void _toggleMember(String its) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedMemberITs.contains(its)) {
        _selectedMemberITs.remove(its);
      } else {
        _selectedMemberITs.add(its);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointBloc, AppointBlocState>(
      listener: (context, state) {
        // Handle successful submission
        if (state is AppointBlocStateAppointmentSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Members appointed successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          // Clear selections
          setState(() => _selectedMemberITs.clear());
          // Fetch events again to go back to initial state
          context.read<AppointBloc>().add(
            const AppointBlocEventFetchActiveEvents(),
          );
        } else if (state is AppointBlocStateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Full screen loading prevents interaction during submission
        if (state is AppointBlocStateLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Appoint Members"),
              backgroundColor: Colors.purple[800],
              foregroundColor: Colors.white,
            ),
            body: Center(child: buildLoadingDialog(context)),
          );
        }

        // 1. Safely Parse State
        List<EventModel> activeEvents = [];
        String? currentEventId;

        if (state is AppointBlocStateInitial) {
          activeEvents = state.activeEvents;
        } else if (state is AppointBlocStateEventSelected) {
          activeEvents = state.activeEvents;
          currentEventId = state.eventId;
        }

        // 2. DROPDOWN FIX: Ensure the currentEventId actually exists in the list
        if (currentEventId != null &&
            !activeEvents.any((e) => e.eventId == currentEventId)) {
          currentEventId = null;
        }

        List<MemberModel> filteredMembers = widget.members.where((m) {
          final query = _searchQuery.toLowerCase();
          return m.name.toLowerCase().contains(query) ||
              m.itsNumber.contains(query);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Appoint Members"),
            backgroundColor: Colors.purple[800],
            foregroundColor: Colors.white,
          ),
          bottomNavigationBar: _buildBottomBar(currentEventId),
          body: _buildBody(activeEvents, currentEventId, filteredMembers),
        );
      },
    );
  }

  Widget _buildBody(
    List<EventModel> activeEvents,
    String? currentEventId,
    List<MemberModel> filteredMembers,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Event",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event),
                  ),
                  items: activeEvents.map((event) {
                    return DropdownMenuItem(
                      value: event.eventId,
                      child: Text(event.eventName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      // MATCHES YOUR BLOC: Select Event
                      context.read<AppointBloc>().add(
                        AppointBlocEventSelectEvent(eventId: val),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "Search members...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (currentEventId != null)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              height: 40,
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Showing ${filteredMembers.length} members",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),

        // Only show list if an event is selected
        if (currentEventId != null)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final member = filteredMembers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: CheckboxListTile(
                  title: Text(
                    member.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "ITS: ${member.itsNumber} • ${member.markaz.name.toUpperCase()}",
                  ),
                  activeColor: Colors.purple[800],
                  value: _selectedMemberITs.contains(member.itsNumber),
                  onChanged: (val) => _toggleMember(member.itsNumber),
                ),
              );
            }, childCount: filteredMembers.length),
          ),

        // Empty State if no event selected
        if (currentEventId == null && activeEvents.isNotEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                "Please select an event to view members.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

        // Bottom padding to ensure the last item is never hidden behind the navigation bar
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildBottomBar(String? currentEventId) {
    int count = _selectedMemberITs.length;
    bool canSubmit = count > 0 && currentEventId != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit ? Colors.purple[800] : Colors.grey,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: canSubmit
            ? () {
                final selectedAttendance = widget.members
                    .where((m) => _selectedMemberITs.contains(m.itsNumber))
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
                    selectedMembers: selectedAttendance,
                  ),
                );
              }
            : null,
        child: Text(
          count == 0 ? "Select Members" : "Appoint $count Members",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(context, shrink, overlaps) => child;
  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate old) => true;
}
