import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_func.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_state.dart';
import 'package:bgk_ladies/constants/routes.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBlocFunc>().state;
    final currentUser = authState is AuthBlocStateLoggedIn
        ? authState.user
        : null;
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
            const Text(
              "Quick Stats",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 1. Stats Ribbon (Horizontal Cards)
            const Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: "Total Members",
                    value: "150",
                    icon: Icons.people,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: "Active Markaz",
                    value: "4",
                    icon: Icons.location_on,
                  ),
                ),
              ],
            ),
            Scrollable(
              axisDirection: AxisDirection.right,
              scrollBehavior: const ScrollBehavior().copyWith(
                scrollbars: false,
              ),
              viewportBuilder: (context, position) {
                return GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3, // Wider buttons
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 20),

                  children: [
                    if (currentUser!.canManageEvents)
                      navButton(
                        context: context,
                        icon: const Icon(Icons.event),
                        label: "Manage Events",
                        onPressed: () {
                          Navigator.pushNamed(context, eventManagementRoute);
                        },
                      ),

                    if (currentUser.canViewReports)
                      navButton(
                        //TODO: Implement reports view
                        context: context,
                        icon: const Icon(Icons.bar_chart),
                        label: "View Reports",
                        onPressed: () {},
                      ),

                    if (currentUser.canCreateUser)
                      navButton(
                        context: context,
                        icon: const Icon(Icons.person_add),
                        label: "Create User",
                        onPressed: () {
                          Navigator.pushNamed(context, registerRoute);
                        },
                      ),

                    if (currentUser.canAppoint)
                      navButton(
                        //TODO: Implement appointment flow
                        context: context,
                        icon: const Icon(Icons.assignment_ind),
                        label: "Appoint",
                        onPressed: () {},
                      ),

                    if (currentUser.canMarkAttendance)
                      navButton(
                        //TODO: Implement attendance marking flow
                        context: context,
                        icon: const Icon(Icons.check_circle),
                        label: "Mark Attendance",
                        onPressed: () {},
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
                  return const LoadingDialog();
                }
                if (state is EventStateLoaded) {
                  final activeEvents = state.activeEvents;

                  if (activeEvents.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Critical for Column usage
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeEvents.length,
                    itemBuilder: (context, index) {
                      final event = activeEvents[index];
                      return _EventCard(event: event);
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy, color: Colors.grey, size: 40),
          SizedBox(height: 10),
          Text(
            "No active events at the moment.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Custom widget for the Stats
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.purple.withAlpha(10),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// Custom widget for Event Items
class _EventCard extends StatelessWidget {
  final EventModel event; // Use your EventModel type here
  const _EventCard({required this.event});

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
        subtitle: const Text("Tap to view details or mark attendance"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to Attendance or Details screen
        },
      ),
    );
  }
}

Widget navButton({
  required BuildContext context,
  required String label,
  required Icon icon,
  required VoidCallback onPressed,
}) {
  return ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    onPressed: onPressed,
    icon: icon,
    label: Text(label),
  );
}
