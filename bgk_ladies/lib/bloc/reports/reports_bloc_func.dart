import 'package:bgk_ladies/bloc/reports/reports_bloc_events.dart';
import 'package:bgk_ladies/bloc/reports/reports_bloc_states.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/services/attend/attend_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsBloc extends Bloc<ReportsBlocEvent, ReportsBlocState> {
  final AttendService _attendService;

  ReportsBloc(AttendService attendService)
    : _attendService = attendService,
      super(const ReportsBlocStateInitial()) {
    // ── Select Event (Tab 1) ──────────────────────────────────────────────────
    on<ReportsBlocEventSelectEvent>((event, emit) async {
      emit(const ReportsBlocStateLoading());
      try {
        await emit.forEach<List<AttendanceModel>>(
          _attendService.getEventAttendance(eventId: event.eventId),
          onData: (data) {
            // Filter raw stream to only members this user can manage
            final managed = event.managedItsNumbers.isEmpty
                ? data
                : data
                    .where((a) => event.managedItsNumbers.contains(a.itsNumber))
                    .toList();
            return ReportsBlocStateEventReportLoaded(
              eventId: event.eventId,
              allAttendance: managed,
              filteredAttendance: managed,
            );
          },
          onError: (error, _) =>
              ReportsBlocStateError(errorMessage: error.toString()),
        );
      } catch (e) {
        emit(ReportsBlocStateError(errorMessage: e.toString()));
      }
    });

    // ── Apply Filter (Tab 1) ──────────────────────────────────────────────────
    on<ReportsBlocEventApplyEventFilter>((event, emit) {
      final current = state;
      if (current is! ReportsBlocStateEventReportLoaded) return;

      var filtered = current.allAttendance;

      if (event.nameFilter != null && event.nameFilter!.isNotEmpty) {
        final q = event.nameFilter!.toLowerCase();
        filtered = filtered
            .where((a) => a.name.toLowerCase().contains(q))
            .toList();
      }
      if (event.glFilter != null && event.glFilter!.isNotEmpty) {
        final q = event.glFilter!.toLowerCase();
        filtered = filtered
            .where((a) => a.glName.toLowerCase().contains(q))
            .toList();
      }
      if (event.mohallaFilter != null && event.mohallaFilter!.isNotEmpty) {
        final q = event.mohallaFilter!.toLowerCase();
        filtered = filtered
            .where((a) => a.mohalla.toLowerCase().contains(q))
            .toList();
      }
      if (event.markazFilter != null) {
        filtered = filtered
            .where((a) => a.markaz == event.markazFilter)
            .toList();
      }
      if (event.statusFilter != null) {
        filtered = filtered
            .where((a) => a.status == event.statusFilter)
            .toList();
      }

      emit(ReportsBlocStateEventReportLoaded(
        eventId: current.eventId,
        allAttendance: current.allAttendance,
        filteredAttendance: filtered,
        nameFilter: event.nameFilter,
        glFilter: event.glFilter,
        mohallaFilter: event.mohallaFilter,
        markazFilter: event.markazFilter,
        statusFilter: event.statusFilter,
      ));
    });

    // ── Select Member (member detail) ─────────────────────────────────────────
    on<ReportsBlocEventSelectMember>((event, emit) async {
      emit(const ReportsBlocStateMemberHistoryLoading());
      try {
        final history = await _attendService.getMemberHistory(
          itsNumber: event.itsNumber,
          allEventIds: event.allEventIds,
        );
        emit(ReportsBlocStateMemberHistoryLoaded(
          itsNumber: event.itsNumber,
          memberName: event.memberName,
          history: history,
        ));
      } catch (e) {
        emit(ReportsBlocStateError(errorMessage: e.toString()));
      }
    });

    // ── Reset ─────────────────────────────────────────────────────────────────
    on<ReportsBlocEventReset>((event, emit) {
      emit(const ReportsBlocStateInitial());
    });
  }
}
