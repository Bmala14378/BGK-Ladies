import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ReportsBlocState {
  const ReportsBlocState();
}

class ReportsBlocStateInitial extends ReportsBlocState {
  const ReportsBlocStateInitial();
}

class ReportsBlocStateLoading extends ReportsBlocState {
  const ReportsBlocStateLoading();
}

/// Loaded state for Tab 1 — per-event attendance breakdown.
class ReportsBlocStateEventReportLoaded extends ReportsBlocState {
  final String eventId;

  /// All attendance records for this event, already filtered to managed members.
  final List<AttendanceModel> allAttendance;

  /// Subset of [allAttendance] after the user's active filter/sort is applied.
  final List<AttendanceModel> filteredAttendance;

  // Active filter values (kept so the UI can reflect current state)
  final String? nameFilter;
  final String? glFilter;
  final String? mohallaFilter;
  final MarkazEnum? markazFilter;
  final StatusEnum? statusFilter;

  const ReportsBlocStateEventReportLoaded({
    required this.eventId,
    required this.allAttendance,
    required this.filteredAttendance,
    this.nameFilter,
    this.glFilter,
    this.mohallaFilter,
    this.markazFilter,
    this.statusFilter,
  });
}

class ReportsBlocStateMemberHistoryLoading extends ReportsBlocState {
  const ReportsBlocStateMemberHistoryLoading();
}

/// Loaded state for Tab 2 — a single member's history across all events.
class ReportsBlocStateMemberHistoryLoaded extends ReportsBlocState {
  final String itsNumber;
  final String memberName;

  /// One record per event the member was appointed/attended.
  final List<AttendanceModel> history;

  const ReportsBlocStateMemberHistoryLoaded({
    required this.itsNumber,
    required this.memberName,
    required this.history,
  });
}

class ReportsBlocStateError extends ReportsBlocState {
  final String errorMessage;
  const ReportsBlocStateError({required this.errorMessage});
}
