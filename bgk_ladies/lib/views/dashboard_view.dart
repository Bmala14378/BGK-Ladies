import 'dart:developer' as devtools;

import 'package:bgk_ladies/bloc/appoint/appoint_bloc_event.dart';
import 'package:bgk_ladies/bloc/appoint/appoint_bloc_func.dart';
import 'package:bgk_ladies/bloc/attend/attend_bloc_events.dart';
import 'package:bgk_ladies/bloc/attend/attend_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_events.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_func.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_state.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_events.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_func.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_states.dart';
import 'package:bgk_ladies/constants/routes.dart';
import 'package:bgk_ladies/enums/user_role_enum.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:bgk_ladies/views/attend/appoint_view.dart';
import 'package:bgk_ladies/views/attend/attend_view.dart';
import 'package:bgk_ladies/widgets/empty_state.dart';
import 'package:bgk_ladies/widgets/event_card.dart';
import 'package:bgk_ladies/widgets/quick_action_button.dart';
import 'package:bgk_ladies/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBlocFunc>().state;
    // ignore: unused_local_variable
    final currentIts = (authState is AuthBlocStateLoggedIn)
        ? authState.user.itsNumber
        : null;
    final currentUser = authState is AuthBlocStateLoggedIn
        ? authState.user
        : null;

    final memberState = context.watch<MemberBloc>().state;
    if (currentUser?.role != UserRoleEnum.onGroundAdmin) {
      if (authState is AuthBlocStateLoggedIn) {
        final memberBloc = context.read<MemberBloc>();
        if (memberBloc.state is InitialMemberBlocState) {
          memberBloc.add(MemberBlocEventInitialize(user: authState.user));
        }
      }
      if (memberState is LoadedMemberBlocState) {
        // Use the pre-fetched profile directly from the state!
        final myInfo = memberState.userProfile;
        final totalMembers = memberState.members.length;
        return DashboardViewWidget(
          currentUser: currentUser!,
          myInfo: myInfo!,
          totalMembers: totalMembers,
          eventId: context.read<EventBloc>().state is EventStateLoaded
              ? (context.read<EventBloc>().state as EventStateLoaded)
                    .activeEvents
                    .first
                    .eventId
              : "",
        );
      } else if (memberState is MemberStateError) {
        devtools.log(
          "MemberBloc is still loading or failed to load. Current state: ${memberState.errorMessage}",
        );
        return Scaffold(body: Center(child: buildLoadingDialog(context)));
      } else {
        devtools.log(
          "MemberBloc is still loading. Current state: ${memberState.runtimeType}",
        );
        return Scaffold(body: Center(child: buildLoadingDialog(context)));
      }
    } else {
      return AttendanceView();
    }
  }
}

class DashboardViewWidget extends StatelessWidget {
  final MemberModel myInfo;
  final int totalMembers;
  final UserModel currentUser;
  final String eventId;
  const DashboardViewWidget({
    super.key,
    required this.currentUser,
    required this.myInfo,
    required this.totalMembers,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.read<AttendBloc>().add(const AttendBlocEventReset());
              context.read<AppointBloc>().add(const AppointBlocEventReset());
              context.read<MemberBloc>().add(const MemberBlocEventReset());
              context.read<EventBloc>().add(const EventBlocEventReset());
              context.read<AuthBlocFunc>().add(const AuthBlocEventLogOut());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withAlpha(50)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Welcome Back, ${myInfo.name} !",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Quick Stats",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 1. Stats Ribbon (Horizontal Cards)
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: "Total Members",
                    value: totalMembers.toString(),
                    icon: Icons.people,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: StatCard(
                    label: "Active Markaz",
                    value: "4",
                    icon: Icons.location_on,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 2. Quick Actions (Conditional Buttons)
            Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Scrollable(
              axisDirection: AxisDirection.right,
              scrollBehavior: const ScrollBehavior().copyWith(
                scrollbars: false,
              ),
              viewportBuilder: (context, position) {
                // GridView inside SingleChildScrollView requires shrinkWrap & NeverScrollableScrollPhysics
                return GridView.count(
                  crossAxisCount: 2, // 2 columns
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    if (currentUser.canManageEvents)
                      QuickActionButton(
                        icon: Icons.event,
                        label: "Manage Events",
                        onPressed: () {
                          Navigator.pushNamed(context, eventManagementRoute);
                        },
                      ),

                    if (currentUser.canViewReports)
                      QuickActionButton(
                        //TODO: Implement reports view
                        icon: Icons.bar_chart,
                        label: "View Reports",
                        onPressed: () {},
                      ),

                    if (currentUser.canAppoint)
                      QuickActionButton(
                        icon: Icons.assignment_ind,
                        label: "Appoint",
                        onPressed: () {
                          final memberState = context.read<MemberBloc>().state;

                          if (memberState is LoadedMemberBlocState) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AppointView(members: memberState.members),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please wait, members are still loading...',
                                ),
                              ),
                            );
                          }
                        },
                      ),

                    if (currentUser.canMarkAttendance)
                      QuickActionButton(
                        icon: Icons.check_circle,
                        label: "Mark Attendance",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendanceView(),
                            ),
                          );
                        },
                      ),

                    if (currentUser.canCreateUser)
                      QuickActionButton(
                        icon: Icons.person_add,
                        label: "Create User",
                        onPressed: () {
                          Navigator.pushNamed(context, registerRoute);
                        },
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 25),
            const Text(
              "Active Events",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 2. Active Events List (Driven by EventBloc)
            BlocBuilder<EventBloc, EventBlocState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return Center(child: buildLoadingDialog(context));
                }
                if (state is EventStateLoaded) {
                  final activeEvents = state.activeEvents;

                  if (activeEvents.isEmpty) {
                    return buildEmptyState();
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Critical for Column usage
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeEvents.length,
                    itemBuilder: (context, index) {
                      final event = activeEvents[index];
                      return EventCard(event: event);
                    },
                  );
                }
                return const Text("Unable to load events.");
              },
            ),
          ],
        ),
      ),
    );
  }
}
