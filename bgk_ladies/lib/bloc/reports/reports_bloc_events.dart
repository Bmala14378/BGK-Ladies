import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ReportsBlocEvent {
  const ReportsBlocEvent();
}

/// Select an event for Tab 1. Pass the role-scoped ITS numbers so the BLoC
/// can filter the raw attendance stream to only manageable members.
class ReportsBlocEventSelectEvent extends ReportsBlocEvent {
  final String eventId;
  final List<String> managedItsNumbers;
  const ReportsBlocEventSelectEvent({
    required this.eventId,
    required this.managedItsNumbers,
  });
}

/// Update the active filter/sort on the event report.
class ReportsBlocEventApplyEventFilter extends ReportsBlocEvent {
  final String? nameFilter;
  final String? glFilter;
  final String? mohallaFilter;
  final MarkazEnum? markazFilter;
  final StatusEnum? statusFilter;
  const ReportsBlocEventApplyEventFilter({
    this.nameFilter,
    this.glFilter,
    this.mohallaFilter,
    this.markazFilter,
    this.statusFilter,
  });
}

/// Fetch attendance history for a single member across all events (Tab 2).
///
/// Pass [allEventIds] from EventBloc so the query does direct document reads
/// instead of a collectionGroup scan (no Firestore index required).
class ReportsBlocEventSelectMember extends ReportsBlocEvent {
  final String itsNumber;
  final String memberName;

  /// IDs of every event to check — from EventBloc.state.allEvents.
  final List<String> allEventIds;

  const ReportsBlocEventSelectMember({
    required this.itsNumber,
    required this.memberName,
    required this.allEventIds,
  });
}

/// Reset the BLoC back to its initial state.
class ReportsBlocEventReset extends ReportsBlocEvent {
  const ReportsBlocEventReset();
}
