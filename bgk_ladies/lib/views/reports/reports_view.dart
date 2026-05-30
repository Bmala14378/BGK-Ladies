// ignore_for_file: use_build_context_synchronously

import 'package:bgk_ladies/bloc/auth/auth_bloc_func.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_func.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_state.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_events.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_func.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_states.dart';
import 'package:bgk_ladies/bloc/reports/reports_bloc_events.dart';
import 'package:bgk_ladies/bloc/reports/reports_bloc_func.dart';
import 'package:bgk_ladies/bloc/reports/reports_bloc_states.dart';
import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:bgk_ladies/themes.dart';
import 'package:bgk_ladies/utilites/csv_util.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:bgk_ladies/views/member/add_edit_member_view.dart';
import 'package:bgk_ladies/views/reports/member_detail_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _statusColor(StatusEnum status) {
  switch (status) {
    case StatusEnum.present:
      return AppTheme.statusPresent;
    case StatusEnum.late:
      return AppTheme.statusLate;
    case StatusEnum.absent:
      return AppTheme.statusAbsent;
    case StatusEnum.appointed:
      return Colors.blue;
    case StatusEnum.na:
      return Colors.grey;
  }
}

IconData _statusIcon(StatusEnum status) {
  switch (status) {
    case StatusEnum.present:
      return Icons.check_circle_outline;
    case StatusEnum.late:
      return Icons.access_time;
    case StatusEnum.absent:
      return Icons.cancel_outlined;
    case StatusEnum.appointed:
      return Icons.assignment_ind_outlined;
    case StatusEnum.na:
      return Icons.help_outline;
  }
}


// ── Entry point ───────────────────────────────────────────────────────────────

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBlocFunc>().state;
    final UserModel? currentUser =
        authState is AuthBlocStateLoggedIn ? authState.user : null;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Event Report'),
              Tab(text: 'Member List'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _EventReportTab(currentUser: currentUser),
            _MemberListTab(currentUser: currentUser),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Tab 1 — Event Report
// ══════════════════════════════════════════════════════════════════════════════

class _EventReportTab extends StatefulWidget {
  final UserModel? currentUser;
  const _EventReportTab({required this.currentUser});

  @override
  State<_EventReportTab> createState() => _EventReportTabState();
}

class _EventReportTabState extends State<_EventReportTab> {
  String? _selectedEventId;
  final TextEditingController _nameFilterCtrl = TextEditingController();
  StatusEnum? _selectedStatus;
  String? _selectedGl;

  @override
  void dispose() {
    _nameFilterCtrl.dispose();
    super.dispose();
  }

  void _onEventSelected(String eventId) {
    setState(() {
      _selectedEventId = eventId;
      _selectedStatus = null;
      _selectedGl = null;
      _nameFilterCtrl.clear();
    });
    final memberState = context.read<MemberBloc>().state;
    final managedIts = memberState is LoadedMemberBlocState
        ? memberState.members.map((m) => m.itsNumber).toList()
        : <String>[];
    context.read<ReportsBloc>().add(
      ReportsBlocEventSelectEvent(
        eventId: eventId,
        managedItsNumbers: managedIts,
      ),
    );
  }

  void _applyFilter() {
    context.read<ReportsBloc>().add(
      ReportsBlocEventApplyEventFilter(
        nameFilter:
            _nameFilterCtrl.text.isEmpty ? null : _nameFilterCtrl.text,
        statusFilter: _selectedStatus,
        glFilter: _selectedGl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Event dropdown ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: BlocBuilder<EventBloc, EventBlocState>(
            builder: (context, eventState) {
              final events = eventState is EventStateLoaded
                  ? eventState.allEvents
                  : <dynamic>[];
              // ignore: deprecated_member_use
              return DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedEventId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Event',
                  prefixIcon: Icon(Icons.event),
                ),
                hint: const Text('Choose an event…'),
                items: events
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.eventId as String,
                        child: Text(
                          e.eventName as String,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) _onEventSelected(val);
                },
              );
            },
          ),
        ),

        // ── Data area ───────────────────────────────────────────────────────
        Expanded(
          child: BlocBuilder<ReportsBloc, ReportsBlocState>(
            builder: (context, state) {
              if (state is ReportsBlocStateLoading) {
                return Center(child: buildLoadingDialog(context));
              }
              if (state is ReportsBlocStateError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
              if (state is ReportsBlocStateEventReportLoaded) {
                return _buildReportContent(state);
              }
              // No event selected yet
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Select an event to view report',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Full report content ─────────────────────────────────────────────────────
  Widget _buildReportContent(ReportsBlocStateEventReportLoaded state) {
    final all = state.allAttendance;
    final filtered = state.filteredAttendance;

    final total = all.length;
    final present = all.where((a) => a.status == StatusEnum.present).length;
    final late = all.where((a) => a.status == StatusEnum.late).length;
    final absent = all.where((a) => a.status == StatusEnum.absent).length;

    final presentPct = total > 0 ? (present / total * 100).round() : 0;
    final latePct = total > 0 ? (late / total * 100).round() : 0;
    final absentPct = total > 0 ? (absent / total * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary cards ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ReportStatCard(
                  label: 'Appointed',
                  value: '$total',
                  icon: Icons.group,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ReportStatCard(
                  label: 'Present',
                  value: '$present\n($presentPct%)',
                  icon: Icons.check_circle_outline,
                  color: AppTheme.statusPresent,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ReportStatCard(
                  label: 'Late',
                  value: '$late\n($latePct%)',
                  icon: Icons.access_time,
                  color: AppTheme.statusLate,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ReportStatCard(
                  label: 'Absent',
                  value: '$absent\n($absentPct%)',
                  icon: Icons.cancel_outlined,
                  color: AppTheme.statusAbsent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Pie chart ─────────────────────────────────────────────────────
          if (present + late + absent > 0) ...[
            const Text(
              'Status Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPieChart(present, late, absent),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppTheme.statusPresent, label: 'Present'),
                const SizedBox(width: 16),
                _LegendDot(color: AppTheme.statusLate, label: 'Late'),
                const SizedBox(width: 16),
                _LegendDot(color: AppTheme.statusAbsent, label: 'Absent'),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // ── Bar chart: by markaz ──────────────────────────────────────────
          const Text(
            'By Markaz',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildMarkazBarChart(all),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppTheme.statusPresent, label: 'Present'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.statusLate, label: 'Late'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.statusAbsent, label: 'Absent'),
            ],
          ),
          const SizedBox(height: 20),

          // ── Bar chart: by GL ──────────────────────────────────────────────
          const Text(
            'Attendance Rate by Group Leader',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildGlBarChart(all),
          const SizedBox(height: 20),

          // ── Filters ───────────────────────────────────────────────────────
          const Text(
            'Filter Records',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameFilterCtrl,
            onChanged: (_) => _applyFilter(),
            decoration: InputDecoration(
              hintText: 'Search by name…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _nameFilterCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _nameFilterCtrl.clear();
                        _applyFilter();
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          // ── GL filter dropdown ──────────────────────────────────────────
          Builder(
            builder: (_) {
              final gls = all
                  .map((a) => a.glName)
                  .where((g) => g.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();
              if (gls.isEmpty) return const SizedBox.shrink();
              return DropdownButtonFormField<String?>(
                // ignore: deprecated_member_use
                value: _selectedGl,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Group Leader',
                  prefixIcon: Icon(Icons.group_outlined),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Group Leaders'),
                  ),
                  ...gls.map(
                    (g) => DropdownMenuItem<String?>(
                      value: g,
                      child: Text(g, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (val) {
                  setState(() => _selectedGl = val);
                  _applyFilter();
                },
              );
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (_) {
                    setState(() => _selectedStatus = null);
                    _applyFilter();
                  },
                ),
                const SizedBox(width: 8),
                ...StatusEnum.values.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(s.displayName),
                      selected: _selectedStatus == s,
                      selectedColor: _statusColor(s).withAlpha(50),
                      onSelected: (_) {
                        setState(
                          () => _selectedStatus =
                              _selectedStatus == s ? null : s,
                        );
                        _applyFilter();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Filtered list ─────────────────────────────────────────────────
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No records match the filter.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...filtered.map((a) => _AttendanceListTile(record: a)),

          // ── Export button ─────────────────────────────────────────────────
          if (all.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export CSV'),
                onPressed: () => exportAttendanceToCsv(
                  records: filtered.isNotEmpty ? filtered : all,
                  fileName: 'Event_Report_${state.eventId}',
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Charts ──────────────────────────────────────────────────────────────────

  Widget _buildPieChart(int present, int late, int absent) {
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: present.toDouble(),
              color: AppTheme.statusPresent,
              title: present > 0 ? '$present' : '',
              radius: 65,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            PieChartSectionData(
              value: late.toDouble(),
              color: AppTheme.statusLate,
              title: late > 0 ? '$late' : '',
              radius: 65,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            PieChartSectionData(
              value: absent.toDouble(),
              color: AppTheme.statusAbsent,
              title: absent > 0 ? '$absent' : '',
              radius: 65,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
          centerSpaceRadius: 36,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildMarkazBarChart(List<AttendanceModel> data) {
    final markazList = MarkazEnum.values;
    final groups = <BarChartGroupData>[];

    for (int i = 0; i < markazList.length; i++) {
      final m = markazList[i];
      final mData = data.where((a) => a.markaz == m).toList();
      groups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: mData
                  .where((a) => a.status == StatusEnum.present)
                  .length
                  .toDouble(),
              color: AppTheme.statusPresent,
              width: 14,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: mData
                  .where((a) => a.status == StatusEnum.late)
                  .length
                  .toDouble(),
              color: AppTheme.statusLate,
              width: 14,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: mData
                  .where((a) => a.status == StatusEnum.absent)
                  .length
                  .toDouble(),
              color: AppTheme.statusAbsent,
              width: 14,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: groups,
          groupsSpace: 32,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= markazList.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      markazList[idx].name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
        ),
      ),
    );
  }

  Widget _buildGlBarChart(List<AttendanceModel> data) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text('No data', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    // Group by GL name
    final byGl = <String, List<AttendanceModel>>{};
    for (final a in data) {
      final gl = a.glName.isEmpty ? 'Unknown' : a.glName;
      byGl.putIfAbsent(gl, () => []).add(a);
    }
    final glNames = byGl.keys.toList()..sort();

    const barWidth = 24.0;
    final minWidth = (glNames.length * 60.0 + 60).clamp(300.0, 3000.0);

    final groups = <BarChartGroupData>[];
    for (int i = 0; i < glNames.length; i++) {
      final glData = byGl[glNames[i]]!;
      final attended = glData
          .where(
            (a) =>
                a.status == StatusEnum.present || a.status == StatusEnum.late,
          )
          .length;
      final rate =
          glData.isNotEmpty ? (attended / glData.length * 100) : 0.0;

      Color barColor;
      if (rate >= 80) {
        barColor = AppTheme.statusPresent;
      } else if (rate >= 50) {
        barColor = AppTheme.statusLate;
      } else {
        barColor = AppTheme.statusAbsent;
      }

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: rate,
              color: barColor,
              width: barWidth,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 200,
        width: minWidth,
        child: BarChart(
          BarChartData(
            barGroups: groups,
            maxY: 100,
            groupsSpace: 16,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: 20,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}%',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= glNames.length) {
                      return const SizedBox.shrink();
                    }
                    final name = glNames[idx];
                    final label = name.length > 9
                        ? '${name.substring(0, 8)}…'
                        : name;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(
              show: true,
              drawVerticalLine: false,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Tab 2 — Member List
// ══════════════════════════════════════════════════════════════════════════════

class _MemberListTab extends StatefulWidget {
  final UserModel? currentUser;
  const _MemberListTab({required this.currentUser});

  @override
  State<_MemberListTab> createState() => _MemberListTabState();
}

class _MemberListTabState extends State<_MemberListTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  MarkazEnum? _markazFilter;
  String? _glFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MemberModel> _applyFilter(List<MemberModel> members) {
    var result = members;
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (m) =>
                m.name.toLowerCase().contains(q) ||
                m.itsNumber.contains(q) ||
                m.glName.toLowerCase().contains(q),
          )
          .toList();
    }
    if (_markazFilter != null) {
      result = result.where((m) => m.markaz == _markazFilter).toList();
    }
    if (_glFilter != null && _glFilter!.isNotEmpty) {
      result = result.where((m) => m.glName == _glFilter).toList();
    }
    return result;
  }

  Future<void> _confirmDelete(BuildContext context, MemberModel member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text(
          'Are you sure you want to permanently delete ${member.name} '
          '(${member.itsNumber})? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    context.read<MemberBloc>().add(
      MemberBlocEventDeleteMember(itsNumber: member.itsNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = widget.currentUser?.canManageMembers ?? false;

    return BlocConsumer<MemberBloc, MemberBlocState>(
      // Don't re-render for transient operation states
      buildWhen: (_, curr) =>
          curr is! MemberStateRemarksUpdated &&
          curr is! MemberStateOperationSuccess,
      listenWhen: (_, curr) =>
          curr is MemberStateOperationSuccess || curr is MemberStateError,
      listener: (ctx, s) {
        if (s is MemberStateOperationSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(s.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (s is MemberStateError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(s.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is! LoadedMemberBlocState) {
          return Center(child: buildLoadingDialog(context));
        }

        final filtered = _applyFilter(state.members);

        return Scaffold(
          body: Column(
            children: [
              // ── Search bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name, ITS, or GL…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // ── Markaz filter chips ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _markazFilter == null,
                        onSelected: (_) => setState(() => _markazFilter = null),
                      ),
                      const SizedBox(width: 8),
                      ...MarkazEnum.values.map(
                        (mk) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(mk.name),
                            selected: _markazFilter == mk,
                            onSelected: (_) => setState(
                              () => _markazFilter =
                                  _markazFilter == mk ? null : mk,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Group Leader filter dropdown ───────────────────────────
              Builder(
                builder: (_) {
                  final gls = state.members
                      .map((m) => m.glName)
                      .where((g) => g.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();
                  if (gls.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String?>(
                      // ignore: deprecated_member_use
                      value: _glFilter,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Group Leader',
                        prefixIcon: Icon(Icons.group_outlined),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Group Leaders'),
                        ),
                        ...gls.map(
                          (g) => DropdownMenuItem<String?>(
                            value: g,
                            child: Text(g, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: (val) => setState(() => _glFilter = val),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),

              // ── Count label + Export ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} member${filtered.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    if (filtered.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Export CSV'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => exportMembersToCsv(
                          members: filtered,
                          fileName: 'Members_List',
                        ),
                      ),
                  ],
                ),
              ),

              // ── Member list ────────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No members found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _buildMemberTile(
                          context,
                          filtered[index],
                          canManage,
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: canManage
              ? FloatingActionButton(
                  heroTag: 'roster_fab',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddEditMemberView(),
                    ),
                  ),
                  tooltip: 'Add Member',
                  child: const Icon(Icons.person_add_alt_1),
                )
              : null,
        );
      },
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    MemberModel member,
    bool canManage,
  ) {
    return Card(
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<ReportsBloc>(),
              child: MemberDetailView(
                member: member,
                currentUser: widget.currentUser,
              ),
            ),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight,
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${member.itsNumber} · ${member.glName.isNotEmpty ? member.glName : "No GL"}',
              style: const TextStyle(fontSize: 12),
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    member.markaz.name,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (member.mohalla.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      member.mohalla,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            if (member.remarks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  member.remarks,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: canManage
            ? PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                tooltip: 'Member actions',
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditMemberView(existingMember: member),
                      ),
                    );
                  } else if (value == 'delete') {
                    _confirmDelete(context, member);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              )
            : Icon(Icons.chevron_right, color: Colors.grey.shade400),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Shared helper widgets
// ══════════════════════════════════════════════════════════════════════════════

class _ReportStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _AttendanceListTile extends StatelessWidget {
  final AttendanceModel record;
  const _AttendanceListTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: _statusColor(record.status).withAlpha(30),
          child: Icon(
            _statusIcon(record.status),
            color: _statusColor(record.status),
            size: 18,
          ),
        ),
        title: Text(
          record.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${record.glName.isNotEmpty ? record.glName : "No GL"} · ${record.mohalla} · ${record.markaz.name}',
          style: const TextStyle(fontSize: 11),
        ),
        isThreeLine: false,
        trailing: _StatusBadge(status: record.status),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StatusEnum status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor(status)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
