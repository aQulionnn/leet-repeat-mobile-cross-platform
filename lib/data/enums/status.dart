enum Status { practicing, mastered, frozen }

extension Statusx on Status {
  String get label {
    switch(this) {
      case Status.practicing:
        return 'Practicing';
      case Status.mastered:
        return 'Mastered';
      case Status.frozen:
        return 'Frozen';
    }
  }
}