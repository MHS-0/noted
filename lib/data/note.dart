import 'package:isar/isar.dart';

// Needed for code generation
part 'note.g.dart';

/// A data model representing a single note item in the Isar database
@collection
class Note {
  /// The primary key used in the Isar database
  Id? id;

  /// The title of the note, which is indexed for faster database search.
  @Index(caseSensitive: false, type: IndexType.value)
  String title;

  /// The details of the note, which is indexed for faster database search.
  @Index(caseSensitive: false, type: IndexType.value)
  String details;

  Note(this.title, this.details);
}
