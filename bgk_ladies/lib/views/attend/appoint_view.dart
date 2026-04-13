// ignore: unused_import
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
  String _serchQuery = "";

  void _toggleMember(String its) {
    HapticFeedback.lightImpact(); // Tactile feedback
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
    context.read<AppointBloc>().add(const AppointBlocEventFetchActiveEvents());

    final filteredMembers = widget.members.where((member) {
      final query = _serchQuery.toLowerCase();
      return member.name.toLowerCase().contains(query) ||
          member.itsNumber.contains(query);
    }).toList();

    return BlocConsumer<AppointBloc, AppointBlocState>(
      listener: (context, state) {
        if (state is AppointBlocStateAppointmentSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointments submitted successfully!'),
            ),
          );
          setState(() {
            _selectedMemberITs.clear();
          });
        }
      },
      builder: (context, state) {
        List<EventModel> activeEvents = [];
        // ignore: unused_local_variable
        EventModel? selectedEvent;

        if (state is AppointBlocStateInitial) {
          activeEvents = state.activeEvents;
        } else if (state is AppointBlocStateEventSelected) {
          activeEvents = state.activeEvents;
          selectedEvent = activeEvents.firstWhere(
            (e) => e.eventId == state.eventId,
            orElse: () => activeEvents.first,
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text("Appoint Members"),
                floating: true,
                pinned: true,
                backgroundColor: Colors.purple[50],
                surfaceTintColor: Colors.transparent,
                actions: [
                  if (_selectedMemberITs.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Chip(
                        label: Text(
                          "${_selectedMemberITs.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.purple,
                        side: BorderSide.none,
                        shape: const CircleBorder(),
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<EventModel>(
                          decoration: InputDecoration(
                            hint: Text("Select an event"),
                            labelText: "Select Event",
                            prefixIcon: const Icon(
                              Icons.event_available,
                              color: Colors.purple,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.purple[50]?.withAlpha(30),
                          ),
                          items: activeEvents.map((event) {
                            return DropdownMenuItem(
                              value: event,
                              child: Text(event.eventName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              context.read<AppointBloc>().add(
                                AppointBlocEventSelectEvent(
                                  eventId: val.eventId,
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
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  height: state is AppointBlocStateEventSelected ? 100 : 90,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      children: [
                        if (state is AppointBlocStateEventSelected) ...[
                          const SizedBox(height: 12),
                          TextField(
                            onChanged: (value) =>
                                setState(() => _serchQuery = value),
                            decoration: InputDecoration(
                              hintText: "Search name or ITS...",
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.purple,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (state is AppointBlocStateEventSelected)
                filteredMembers.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(
                          icon: Icons.search_off,
                          message: "No members match your search",
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final member = filteredMembers[index];
                            final isSelected = _selectedMemberITs.contains(
                              member.itsNumber,
                            );
                            return _buildMemberCard(member, isSelected);
                          }, childCount: filteredMembers.length),
                        ),
                      )
              else
                SliverFillRemaining(
                  child: _buildEmptyState(
                    icon: Icons.touch_app_outlined,
                    message: "Select an event to load the member list",
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          bottomSheet: state is AppointBlocStateEventSelected
              ? _buildSubmitButton(state)
              : null,
        );
      },
    );
  }

  Widget _buildMemberCard(MemberModel member, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple[50] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? Colors.purple : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _toggleMember(member.itsNumber),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isSelected ? Colors.purple : Colors.purple[100],
          child: Text(
            member.name[0],
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("ITS: ${member.itsNumber} • ${member.mohalla}"),
        trailing: Checkbox(
          value: isSelected,
          activeColor: Colors.purple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (_) => _toggleMember(member.itsNumber),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.purple[100]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppointBlocStateEventSelected state) {
    final count = _selectedMemberITs.length;
    final isEnabled = count > 0 && state is! AppointBlocStateLoading;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          disabledBackgroundColor: Colors.grey[300],
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: isEnabled
            ? () {
                final selectedAttendance = widget.members
                    .where((m) => _selectedMemberITs.contains(m.itsNumber))
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
              }
            : null,
        child: state is AppointBlocStateLoading
            ? buildLoadingDialog(context)
            : Text(
                count == 0
                    ? "Select Members"
                    : "Appoint $count Member${count > 1 ? 's' : ''}",
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) => true;
}
