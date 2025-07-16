import 'package:meta/meta.dart';

class Theater {
  Theater({
    this.id = 'Not found it null',
    this.name = 'Not found it null',
  });

  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Theater &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
