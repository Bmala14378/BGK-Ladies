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

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBlocFunc>().state;
    final userMarkaz = (authState is AuthBlocStateLoggedIn)
        ? authState.user.markaz
        : null;

    return Scaffold(
      body: BlocBuilder<AttendBloc, AttendBlocState>(
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
                pinned: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      context.read<AttendBloc>().add(
                        const AttendBlocEventFetchActiveEvents(),
                      );
                    },
                    tooltip: "Refresh Events",
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<AttendBloc>().add(
                        const AttendBlocEventReset(),
                      );
                      context.read<AppointBloc>().add(
                        const AppointBlocEventReset(),
                      );
                      context.read<MemberBloc>().add(
                        const MemberBlocEventReset(),
                      );
                      context.read<EventBloc>().add(
                        const EventBlocEventReset(),
                      );
                      context.read<AuthBlocFunc>().add(
                        const AuthBlocEventLogOut(),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: "Logout",
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
                          icon: Icon(Icons.event, color: Colors.purple[800]),
                          isExpanded: true,
                          hint: const Text(
                            "Please Select an Event",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          items: events.map((event) {
                            return DropdownMenuItem(
                              value: event.eventId,
                              child: Text(
                                event.eventName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null && userMarkaz != null) {
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

              // UI rendering logic based on state
              if (state is AttendBlocStateLoading && state.eventId != null)
                SliverFillRemaining(
                  child: Center(child: buildLoadingDialog(context)),
                )
              else if (state is AttendBlocStateError)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      state.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (selectedEventId == null)
                // THIS IS THE FIX: Completely blank space until an event is selected
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

    final attendance = state.attendanceList;
    final present = attendance
        .where((e) => e.status == StatusEnum.present)
        .length;
    final late = attendance.where((e) => e.status == StatusEnum.late).length;
    final absent = attendance
        .where((e) => e.status == StatusEnum.absent)
        .length;

    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: _StickyHeaderDelegate(
          height: 195.0,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by name or ITS...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () =>
                                  setState(() => _searchQuery = ""),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                    _buildStatItem("Total", attendance.length, Colors.blueGrey),
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

      if (filteredList.isEmpty)
        const SliverFillRemaining(
          child: Center(child: Text("No members found matching your search.")),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final record = filteredList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(
                    record.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    "ITS: ${record.itsNumber}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _statusButton(
                        context: context,
                        record: record,
                        status: StatusEnum.present,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      _statusButton(
                        context: context,
                        record: record,
                        status: StatusEnum.late,
                        color: Colors.yellow[800]!,
                      ),
                      const SizedBox(width: 4),
                      _statusButton(
                        context: context,
                        record: record,
                        status: StatusEnum.absent,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }, childCount: filteredList.length),
        ),
    ];
  }

  Widget _statusButton({
    required BuildContext context,
    required dynamic record,
    required StatusEnum status,
    required Color color,
  }) {
    bool isSelected = record.status == status;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        context.read<AttendBloc>().add(
          AttendBlocEventUpdateStatus(
            eventId: (context.read<AttendBloc>().state as AttendBlocStateLoaded)
                .eventId,
            itsNumber: record.itsNumber,
            status: status,
          ),
        );
      },
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
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 28.0,
        top: 12.0,
        bottom: 8.0,
      ),
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
