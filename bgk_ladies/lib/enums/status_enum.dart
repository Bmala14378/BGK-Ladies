enum StatusEnum { na, appointed, present, late, absent }

extension StatusExtension on StatusEnum {
  String get displayName {
    switch (this) {
      case StatusEnum.na:
        return 'N/A';
      case StatusEnum.appointed:
        return 'Appointed';
      case StatusEnum.present:
        return 'Present';
      case StatusEnum.late:
        return 'Late';
      case StatusEnum.absent:
        return 'Absent';
    }
  }
}
