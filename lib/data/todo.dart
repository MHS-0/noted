import 'package:isar/isar.dart';

// Needed for code generation
part 'todo.g.dart';

/// A data model representing a single note item in the Isar database
@collection
class Todo {
  /// The primary key used in the Isar database
  Id? id;

  /// The title of the todo, which is indexed for faster database search.
  @Index(caseSensitive: false, type: IndexType.value)
  String title;

  /// The checked state of the todo
  bool checked;

  Todo(this.title, this.checked);
}
