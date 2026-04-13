// ignore_for_file: unused_import

import 'package:bgk_ladies/bloc/appoint/appoint_bloc_event.dart';
import 'package:bgk_ladies/bloc/appoint/appoint_bloc_func.dart';
import 'package:bgk_ladies/bloc/attend/attend_bloc_events.dart';
import 'package:bgk_ladies/bloc/attend/attend_bloc_func.dart';
import 'package:bgk_ladies/bloc/attend/attend_bloc_states.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_events.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_func.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_events.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_func.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  String _searchQuery = "";
  // 1. ADD: Local map for batch updates
  final Map<String, StatusEnum> _pendingUpdates = {};

  // Helper to show the most recent selection (local or DB)
  StatusEnum _getDisplayStatus(dynamic record) {
    return _pendingUpdates[record.itsNumber] ?? record.status;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBlocFunc>().state;
    final userMarkaz = (authState is AuthBlocStateLoggedIn)
        ? authState.user.markaz
        : null;

    return Scaffold(
      // 3. ADD: Submit Button
      floatingActionButton: _pendingUpdates.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: Colors.purple[800],
              onPressed: () {
                final state = context.read<AttendBloc>().state;
                if (state is AttendBlocStateLoaded) {
                  context.read<AttendBloc>().add(
                    AttendBlocEventSubmitBatch(
                      eventId: state.eventId,
                      attendanceUpdates: _pendingUpdates,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.cloud_upload, color: Colors.white),
              label: Text(
                "Save ${_pendingUpdates.length} Changes",
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      // 2. CHANGE: BlocBuilder to BlocConsumer for listener support
      body: BlocConsumer<AttendBloc, AttendBlocState>(
        listener: (context, state) {
          if (state is AttendBlocStateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Attendance saved successfully!"),
                backgroundColor: Colors.green,
              ),
            );
            setState(() => _pendingUpdates.clear());
            context.read<AttendBloc>().add(
              const AttendBlocEventFetchActiveEvents(),
            );
          } else if (state is AttendBlocStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          List<EventModel> events = [];
          String? selectedEventId;

          if (state is AttendBlocStateInitial) {
            events = state.activeEvents;
          } else if (state is AttendBlocStateLoading) {
            events = state.activeEvents ?? [];
            selectedEventId = state.eventId;
          } else if (state is AttendBlocStateLoaded) {
            events = state.activeEvents;
            selectedEventId = state.eventId;
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text(
                  "Mark Attendance",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.purple[800],
                floating: true,
                snap: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => context.read<AttendBloc>().add(
                      const AttendBlocEventFetchActiveEvents(),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<AttendBloc>().add(
                        const AttendBlocEventReset(),
                      );
                      context.read<AuthBlocFunc>().add(
                        const AuthBlocEventLogOut(),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(80.0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField(
                          initialValue: selectedEventId,
                          icon: Icon(Icons.event, color: Colors.purple[800]),
                          isExpanded: true,
                          hint: const Text(
                            "Please Select an Event",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          items: events
                              .map(
                                (event) => DropdownMenuItem(
                                  value: event.eventId,
                                  child: Text(event.eventName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null && userMarkaz != null) {
                              // 4. ADD: Clear local state on event change
                              setState(() => _pendingUpdates.clear());
                              context.read<AttendBloc>().add(
                                AttendBlocEventFetchAttendance(
                                  eventId: value,
                                  markaz: userMarkaz,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (state is AttendBlocStateLoading && state.eventId != null ||
                  state is AttendBlocStateSubmitting)
                SliverFillRemaining(
                  child: Center(child: buildLoadingDialog(context)),
                )
              else if (selectedEventId == null)
                const SliverToBoxAdapter(child: SizedBox.shrink())
              else if (state is AttendBlocStateLoaded)
                ..._buildLoadedContent(state),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildLoadedContent(AttendBlocStateLoaded state) {
    final filteredList = state.attendanceList.where((member) {
      final query = _searchQuery.toLowerCase();
      return member.name.toLowerCase().contains(query) ||
          member.itsNumber.contains(query);
    }).toList();

    // Stats now include local pending updates for real-time accuracy
    final total = state.attendanceList.length;
    final present = state.attendanceList
        .where((e) => _getDisplayStatus(e) == StatusEnum.present)
        .length;
    final late = state.attendanceList
        .where((e) => _getDisplayStatus(e) == StatusEnum.late)
        .length;
    final absent = state.attendanceList
        .where((e) => _getDisplayStatus(e) == StatusEnum.absent)
        .length;

    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: _StickyHeaderDelegate(
          height: 195.0,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by name or ITS...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("Total", total, Colors.blueGrey),
                    _buildStatItem("Present", present, Colors.green),
                    _buildStatItem("Late", late, Colors.yellow[800]!),
                    _buildStatItem("Absent", absent, Colors.red),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildListHeader(),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final member = filteredList[index];
          final currentStatus = _getDisplayStatus(member);
          // Check if this specific member has unsaved changes
          final bool isDirty = _pendingUpdates.containsKey(member.itsNumber);

          return Card(
            // Change elevation or border if there is an unsaved change
            elevation: isDirty ? 4 : 1,
            shape: isDirty
                ? RoundedRectangleBorder(
                    side: BorderSide(color: Colors.purple[800]!, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              title: Row(
                children: [
                  SizedBox(
                    width: 184,
                    child: Text(
                      member.name,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (isDirty) ...[
                    const SizedBox(width: 8),
                    // Small "Unsaved" indicator
                    Icon(Icons.history, size: 14, color: Colors.purple[800]),
                  ],
                ],
              ),
              subtitle: Text(member.itsNumber),
              trailing: SizedBox(
                width: 125,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statusIcon(
                      StatusEnum.present,
                      Colors.green,
                      currentStatus,
                      member.itsNumber,
                      isDirty,
                    ),
                    _statusIcon(
                      StatusEnum.late,
                      Colors.orange,
                      currentStatus,
                      member.itsNumber,
                      isDirty,
                    ),
                    _statusIcon(
                      StatusEnum.absent,
                      Colors.red,
                      currentStatus,
                      member.itsNumber,
                      isDirty,
                    ),
                  ],
                ),
              ),
            ),
          );
        }, childCount: filteredList.length),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ];
  }

  Widget _statusIcon(
    StatusEnum status,
    Color color,
    StatusEnum current,
    String itsNumber,
    bool isDirty,
  ) {
    bool isSelected = status == current;
    // If it's selected AND unsaved, we make the border thicker/different
    bool isPendingThisStatus = isSelected && isDirty;

    return GestureDetector(
      onTap: () => setState(() => _pendingUpdates[itsNumber] = status),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isPendingThisStatus ? Colors.purple[800]! : color,
            width: isPendingThisStatus
                ? 3
                : 1, // Thicker border for unsaved changes
          ),
          boxShadow: isPendingThisStatus
              ? [
                  BoxShadow(
                    color: color.withAlpha(40),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          isSelected ? Icons.check : Icons.circle_outlined,
          size: 16,
          color: isSelected ? Colors.white : color,
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _statusButton({
    required dynamic record,
    required StatusEnum status,
    required Color color,
  }) {
    // 5. CHANGE: Buttons now update local state instead of firing Bloc events
    bool isSelected = _getDisplayStatus(record) == status;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _pendingUpdates[record.itsNumber] = status),
      child: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? color : Colors.grey[400],
        size: 28,
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 28, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Member Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Present",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  "Late",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800]!,
                  ),
                ),
                const Text(
                  "Absent",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _StickyHeaderDelegate({required this.child, required this.height});
  @override
  Widget build(context, shrink, overlaps) =>
      Container(color: Theme.of(context).scaffoldBackgroundColor, child: child);
  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => true;
}
