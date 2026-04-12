// ignore_for_file: constant_identifier_names

enum MarkazEnum { FK, JM, BR }

extension MarkazExtension on MarkazEnum {
  String get displayName {
    switch (this) {
      case MarkazEnum.FK:
        return 'Fakhri Markaz';
      case MarkazEnum.JM:
        return 'Jamali Markaz';
      case MarkazEnum.BR:
        return 'Badri Markaz';
    }
  }
}
