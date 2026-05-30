import 'dart:convert';
import 'dart:typed_data';

import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:share_plus/share_plus.dart';

/// Generates a CSV from [records] and opens the native share sheet.
///
/// [fileName] is used as the suggested file name (without `.csv`).
Future<void> exportAttendanceToCsv({
  required List<AttendanceModel> records,
  required String fileName,
}) async {
  final buffer = StringBuffer();
  buffer.writeln('ITS Number,Name,GL Name,Mohalla,Markaz,Status,DateTime');

  for (final r in records) {
    // Wrap text fields in quotes to handle embedded commas/spaces
    buffer.writeln(
      [
        r.itsNumber,
        '"${r.name}"',
        '"${r.glName}"',
        '"${r.mohalla}"',
        r.markaz.name,
        r.status.displayName,
        r.dateTime.toIso8601String(),
      ].join(','),
    );
  }

  final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
  final xfile = XFile.fromData(
    bytes,
    mimeType: 'text/csv',
    name: '$fileName.csv',
  );

  await Share.shareXFiles([xfile], subject: fileName);
}

/// Generates a CSV of [members] and opens the native share sheet.
///
/// [fileName] is used as the suggested file name (without `.csv`).
Future<void> exportMembersToCsv({
  required List<MemberModel> members,
  required String fileName,
}) async {
  final buffer = StringBuffer();
  buffer.writeln('ITS Number,Name,GL Name,Mohalla,Markaz,Remarks');

  for (final m in members) {
    buffer.writeln(
      [
        m.itsNumber,
        '"${m.name}"',
        '"${m.glName}"',
        '"${m.mohalla}"',
        m.markaz.name,
        '"${m.remarks.replaceAll('"', '""')}"',
      ].join(','),
    );
  }

  final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
  final xfile = XFile.fromData(
    bytes,
    mimeType: 'text/csv',
    name: '$fileName.csv',
  );

  await Share.shareXFiles([xfile], subject: fileName);
}
