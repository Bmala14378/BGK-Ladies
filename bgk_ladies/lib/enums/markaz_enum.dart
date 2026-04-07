enum MarkazEnum { fakhriMarkaz, jamaliMarkaz, badriMarkaz }

extension MarkazExtension on MarkazEnum {
  String get displayName {
    switch (this) {
      case MarkazEnum.fakhriMarkaz:
        return 'Fakhri Markaz';
      case MarkazEnum.jamaliMarkaz:
        return 'Jamali Markaz';
      case MarkazEnum.badriMarkaz:
        return 'Badri Markaz';
    }
  }
}
