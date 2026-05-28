import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/bloc/reports/reports_bloc_func.dart';
import 'package:bgk_ladies/enums/user_role_enum.dart';
import 'package:bgk_ladies/services/attend/attend_service.dart';
import 'package:bgk_ladies/themes.dart';
import 'package:bgk_ladies/views/auth/profile_view.dart';
import 'package:bgk_ladies/views/dashboard_view.dart';
import 'package:bgk_ladies/views/reports/reports_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RootNavigationPage extends StatefulWidget {
  const RootNavigationPage({super.key});

  @override
  State<RootNavigationPage> createState() => _RootNavigationPageState();
}

class _RootNavigationPageState extends State<RootNavigationPage> {
  // 0 = Dashboard (Home), 1 = Reports, 2 = Profile
  int _selectedIndex = 0;

  late final List<Widget> _views = [
    const DashboardView(),
    BlocProvider<ReportsBloc>(
      create: (_) => ReportsBloc(AttendService()),
      child: const ReportsView(),
    ),
    const ProfileView(),
  ];

  // Icons either side of the center FAB notch
  final List<IconData> iconList = [
    Icons.bar_chart_rounded,     // Reports
    Icons.person_outline_rounded, // Profile
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // onGroundAdmin goes directly to DashboardView (which internally shows
    // AttendanceView). They have no access to Reports or Profile, so the
    // bottom nav bar and FAB are hidden entirely.
    final authState = context.read<AuthBlocFunc>().state;
    final role = authState is AuthBlocStateLoggedIn
        ? authState.user.role
        : null;
    final isOnGroundAdmin = role == UserRoleEnum.onGroundAdmin;

    if (isOnGroundAdmin) {
      return const Scaffold(body: DashboardView());
    }

    return Scaffold(
      // IndexedStack preserves state when switching tabs
      body: IndexedStack(index: _selectedIndex, children: _views),

      // Center "Home" FAB
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: _selectedIndex == 0
            ? AppTheme.primaryDark
            : Colors.grey.shade300,
        elevation: _selectedIndex == 0 ? 4 : 0,
        onPressed: () => setState(() => _selectedIndex = 0),
        child: Icon(
          Icons.home_rounded,
          color: _selectedIndex == 0 ? Colors.white : Colors.grey.shade700,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: colorScheme.surface,
        icons: iconList,
        activeIndex: _selectedIndex == 2 ? 1 : 0,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 20,
        rightCornerRadius: 20,
        activeColor: _selectedIndex == 0
            ? Colors.grey.shade400
            : colorScheme.primary,
        inactiveColor: Colors.grey.shade400,
        iconSize: 28,
        onTap: (index) {
          setState(() {
            // Nav bar index 0 → Reports (view index 1)
            // Nav bar index 1 → Profile (view index 2)
            _selectedIndex = index == 0 ? 1 : 2;
          });
        },
      ),
    );
  }
}
