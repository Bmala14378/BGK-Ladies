// ignore_for_file: use_build_context_synchronously

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
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:bgk_ladies/themes.dart';
import 'package:bgk_ladies/utilites/csv_util.dart';
import 'package:bgk_ladies/utilites/dialog/loading_dialog.dart';
import 'package:bgk_ladies/views/member/add_edit_member_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Private helpers ───────────────────────────────────────────────────────────

Color _statusColor(StatusEnum s) {
  switch (s) {
    case StatusEnum.present:
      return Colors.green;
    case StatusEnum.late:
      return Colors.yellow.shade800;
    case StatusEnum.absent:
      return Colors.red;
    case StatusEnum.appointed:
      return Colors.blue;
    case StatusEnum.na:
      return Colors.grey;
  }
}

IconData _statusIcon(StatusEnum s) {
  switch (s) {
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

String _fmtDate(DateTime dt) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
}

/// Resolves the event name for a given [eventId] against the loaded event list.
/// Falls back to a formatted date string when the event is not found or the
/// eventId is empty (e.g. attendance recorded before eventId injection).
String _lookupEventName(
  String eventId,
  List<EventModel> events, [
  DateTime? fallback,
]) {
  if (eventId.isNotEmpty) {
    final match = events.where((e) => e.eventId == eventId).firstOrNull;
    if (match != null && match.eventName.isNotEmpty) return match.eventName;
  }
  return fallback != null ? _fmtDate(fallback) : 'Unknown Event';
}

/// Returns 1-2 short label lines for a bar chart X-axis.
/// Examples:
///   "Ashara Mubaraka 1446" → ["Ashara", "1446"]
///   "Eid Milad"            → ["Eid", "Milad"]
///   "Muharram"             → ["Muharram"]
List<String> _abbrevEventName(String name) {
  final trimmed = name.trim();
  final parts = trimmed.split(' ');
  if (trimmed.length <= 11) return [trimmed];
  // Last token is a 3-4 digit year → keep first word + year
  if (parts.length >= 2 && RegExp(r'^\d{3,4}$').hasMatch(parts.last)) {
    return [parts.first, parts.last];
  }
  // Two words that together fit on two short lines
  if (parts.length == 2) {
    final a = parts[0].length > 7 ? '${parts[0].substring(0, 6)}.' : parts[0];
    final b = parts[1].length > 7 ? '${parts[1].substring(0, 6)}.' : parts[1];
    return [a, b];
  }
  // General: first word + last word
  return [parts.first, parts.last];
}

// ── Main view ─────────────────────────────────────────────────────────────────

class MemberDetailView extends StatefulWidget {
  final MemberModel member;
  final UserModel? currentUser;

  const MemberDetailView({
    super.key,
    required this.member,
    required this.currentUser,
  });

  @override
  State<MemberDetailView> createState() => _MemberDetailViewState();
}

class _MemberDetailViewState extends State<MemberDetailView> {
  late String _currentRemarks;

  @override
  void initState() {
    super.initState();
    _currentRemarks = widget.member.remarks;
    // Kick off history fetch after first frame so BLoC context is ready.
    // Read event IDs from the globally-provided EventBloc — direct doc reads,
    // no Firestore collectionGroup index required.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final eventState = context.read<EventBloc>().state;
        final allEventIds = eventState is EventStateLoaded
            ? eventState.allEvents.map((e) => e.eventId).toList()
            : <String>[];

        context.read<ReportsBloc>().add(
          ReportsBlocEventSelectMember(
            itsNumber: widget.member.itsNumber,
            memberName: widget.member.name,
            allEventIds: allEventIds,
          ),
        );
      }
    });
  }

  // ── Remarks dialog ──────────────────────────────────────────────────────────
  void _editRemarks(BuildContext context) {
    final ctrl = TextEditingController(text: _currentRemarks);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Remarks'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter remarks…',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = ctrl.text.trim();
              context.read<MemberBloc>().add(
                MemberBlocEventUpdateRemarks(
                  itsNumber: widget.member.itsNumber,
                  remarks: text,
                ),
              );
              setState(() => _currentRemarks = text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser?.canEditRemarks ?? false;
    final canManage = widget.currentUser?.canManageMembers ?? false;

    return BlocListener<MemberBloc, MemberBlocState>(
      listenWhen: (_, curr) => curr is MemberStateRemarksUpdated,
      listener: (ctx, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remarks updated'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.member.name),
          actions: [
            if (canManage)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Member',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditMemberView(existingMember: widget.member),
                  ),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Member info card ────────────────────────────────────────
              _MemberInfoCard(member: widget.member),
              const SizedBox(height: 14),

              // ── Remarks card ────────────────────────────────────────────
              _RemarksCard(
                remarks: _currentRemarks,
                canEdit: canEdit,
                onEdit: () => _editRemarks(context),
              ),
              const SizedBox(height: 20),

              // ── Attendance history ──────────────────────────────────────
              const Text(
                'Attendance History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              BlocBuilder<ReportsBloc, ReportsBlocState>(
                builder: (context, state) {
                  if (state is ReportsBlocStateMemberHistoryLoading) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: buildLoadingDialog(context)),
                    );
                  }
                  if (state is ReportsBlocStateError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (state is ReportsBlocStateMemberHistoryLoaded &&
                      state.itsNumber == widget.member.itsNumber) {
                    return _HistoryContent(state: state);
                  }
                  // Still loading (initial or switched member)
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: buildLoadingDialog(context)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Member info card
// ══════════════════════════════════════════════════════════════════════════════

class _MemberInfoCard extends StatelessWidget {
  final MemberModel member;
  const _MemberInfoCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 34,
              backgroundColor: AppTheme.primaryLight,
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Row(Icons.badge_outlined, member.itsNumber),
                  if (member.glName.isNotEmpty)
                    _Row(Icons.group_outlined, member.glName),
                  if (member.mohalla.isNotEmpty)
                    _Row(Icons.home_outlined, member.mohalla),
                  const SizedBox(height: 8),
                  _MarkazChip(markaz: member.markaz),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Row(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _MarkazChip extends StatelessWidget {
  final MarkazEnum markaz;
  const _MarkazChip({required this.markaz});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        markaz.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryDark,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Remarks card
// ══════════════════════════════════════════════════════════════════════════════

class _RemarksCard extends StatelessWidget {
  final String remarks;
  final bool canEdit;
  final VoidCallback onEdit;

  const _RemarksCard({
    required this.remarks,
    required this.canEdit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Remarks',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (canEdit)
                  TextButton.icon(
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: onEdit,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (remarks.isNotEmpty)
              Text(
                remarks,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              )
            else
              Text(
                canEdit ? 'No remarks yet. Tap Edit to add.' : 'No remarks.',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  History content (stats + chart + list + export)
// ══════════════════════════════════════════════════════════════════════════════

class _HistoryContent extends StatelessWidget {
  final ReportsBlocStateMemberHistoryLoaded state;
  const _HistoryContent({required this.state});

  @override
  Widget build(BuildContext context) {
    // Cross-reference event names — EventBloc is globally provided in main.dart.
    final eventState = context.read<EventBloc>().state;
    final events = eventState is EventStateLoaded
        ? eventState.allEvents
        : <EventModel>[];

    final history = List<AttendanceModel>.from(state.history)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 52, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No attendance records found.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final total = history.length;
    final present =
        history.where((a) => a.status == StatusEnum.present).length;
    final late = history.where((a) => a.status == StatusEnum.late).length;
    final absent =
        history.where((a) => a.status == StatusEnum.absent).length;
    final presentPct = (present / total * 100).round();
    final latePct = (late / total * 100).round();
    final absentPct = (absent / total * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Stat cards ──────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Events',
                value: '$total',
                icon: Icons.event_outlined,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _StatCard(
                label: 'Present',
                value: '$present ($presentPct%)',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _StatCard(
                label: 'Late',
                value: '$late ($latePct%)',
                icon: Icons.access_time,
                color: Colors.yellow.shade800,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _StatCard(
                label: 'Absent',
                value: '$absent ($absentPct%)',
                icon: Icons.cancel_outlined,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Section header ───────────────────────────────────────────────
        Row(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 16,
              color: AppTheme.primaryDark,
            ),
            const SizedBox(width: 6),
            Text(
              'Attendance Timeline',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDark,
              ),
            ),
            const Spacer(),
            if (history.length > 4)
              Text(
                'Scroll to see all',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Bar chart ───────────────────────────────────────────────────
        _HistoryBarChart(history: history, events: events),
        const SizedBox(height: 10),

        // ── Legend ──────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Dot(color: Colors.green, label: 'Present'),
            const SizedBox(width: 16),
            _Dot(color: Colors.yellow.shade800, label: 'Late'),
            const SizedBox(width: 16),
            _Dot(color: Colors.red, label: 'Absent'),
          ],
        ),
        const SizedBox(height: 28),

        // ── Event list header ───────────────────────────────────────────
        Row(
          children: [
            Icon(
              Icons.format_list_bulleted_rounded,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              'Event Records',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            Text(
              '$total event${total == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Event list (newest first) ───────────────────────────────────
        ...history.reversed.map((a) {
          final eventName =
              _lookupEventName(a.eventId, events, a.dateTime);
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: _statusColor(a.status).withAlpha(28),
                child: Icon(
                  _statusIcon(a.status),
                  color: _statusColor(a.status),
                  size: 18,
                ),
              ),
              title: Text(
                eventName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                _fmtDate(a.dateTime),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              trailing: _StatusBadge(status: a.status),
            ),
          );
        }),

        // ── Export ──────────────────────────────────────────────────────
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.download_outlined),
            label: const Text('Export CSV'),
            onPressed: () => exportAttendanceToCsv(
              records: history,
              fileName: 'Member_History_${state.itsNumber}',
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── History bar chart ─────────────────────────────────────────────────────────

class _HistoryBarChart extends StatelessWidget {
  final List<AttendanceModel> history;
  final List<EventModel> events;
  const _HistoryBarChart({required this.history, required this.events});

  @override
  Widget build(BuildContext context) {
    final count = history.length;
    // Wider bars for fewer events — gives the chart appropriate visual weight.
    final barW = count <= 5
        ? 36.0
        : count <= 10
        ? 28.0
        : 22.0;
    final minWidth = (count * (barW + 22.0) + 56.0).clamp(260.0, 4000.0);

    final groups = <BarChartGroupData>[];
    for (int i = 0; i < count; i++) {
      final a = history[i];
      // Bar height encodes status — color + height = double confirmation.
      final barY = switch (a.status) {
        StatusEnum.present => 3.0,
        StatusEnum.late => 2.0,
        StatusEnum.appointed => 1.0,
        _ => 0.5, // absent / na — stub shows the event was tracked
      };
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: barY,
              color: _statusColor(a.status),
              width: barW,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
              // Ghost rod: full-height translucent track behind each bar.
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 3.2,
                color: Colors.grey.withAlpha(18),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: 210,
          width: minWidth,
          child: BarChart(
            BarChartData(
              barGroups: groups,
              maxY: 3.5,
              minY: 0,
              groupsSpace: 8,
              // ── Touch tooltip ────────────────────────────────────────
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppTheme.primaryDark.withAlpha(230),
                  tooltipRoundedRadius: 10,
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  getTooltipItem: (group, _, rod, _) {
                    final a = history[group.x];
                    final name =
                        _lookupEventName(a.eventId, events, a.dateTime);
                    return BarTooltipItem(
                      name,
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: '\n${_fmtDate(a.dateTime)}',
                          style: TextStyle(
                            color: Colors.white.withAlpha(170),
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: '   ${a.status.displayName}',
                          style: TextStyle(
                            color: _statusColor(a.status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // ── Axis titles ──────────────────────────────────────────
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
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
                    reservedSize: 46,
                    getTitlesWidget: (value, _) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= count) {
                        return const SizedBox.shrink();
                      }
                      final a = history[idx];
                      final name =
                          _lookupEventName(a.eventId, events, a.dateTime);
                      final lines = _abbrevEventName(name);
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: lines
                              .where((l) => l.isNotEmpty)
                              .map(
                                (l) => Text(
                                  l,
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    height: 1.35,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              // Dashed horizontal guides — visual reference without clutter.
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.grey.withAlpha(35),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Small shared widgets (local to this file)
// ══════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
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

class _StatusBadge extends StatelessWidget {
  final StatusEnum status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final c = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
