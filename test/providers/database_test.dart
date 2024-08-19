import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:noted/data/note.dart';
import 'package:noted/data/todo.dart';
import 'package:noted/providers/database.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../path_provider_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notes database tests', () {
    final database = Database.instance();
    PathProviderPlatform.instance = FakePathProviderPlatform();

    setUpAll(() async {
      if (Isar.getInstance() != null) return;
      await Isar.initializeIsarCore(download: true);
      await database.load();
    });

    setUp(() async {
      await database.clearDatabase();
    });

    test('Adding a note', () async {
      expect(database.notes.isEmpty, true);
      final testNote = Note('title', 'details');
      await database.addNote(testNote);
      expect(database.notes.single.id, 1);
      expect(database.notes.single.title, 'title');
      expect(database.notes.single.details, 'details');
    });

    test('Removing a note', () async {
      expect(database.notes.isEmpty, true);
      final testNote = Note('title', 'details');
      await database.addNote(testNote);
      expect(database.notes.isNotEmpty, true);
      await database.deleteNote(testNote);
      expect(database.notes.isEmpty, true);
    });

    test('Modifying a Note', () async {
      expect(database.notes.isEmpty, true);
      final testNote = Note('title', 'details');
      await database.addNote(testNote);
      expect(database.notes.isNotEmpty, true);
      testNote.title = 'changedTitle';
      testNote.details = 'changedDetails';
      await database.modifyNote(testNote);
      expect(database.notes.single.id, 1);
      expect(database.notes.single.title, 'changedTitle');
      expect(database.notes.single.details, 'changedDetails');
    });

    test('Title gets filtered (should not be case sensitive)', () async {
      expect(database.notes.isEmpty, true);
      final testNote1 = Note('AAA', 'details');
      final testNote2 = Note('BBB', 'details');
      await database.addNote(testNote1);
      await database.addNote(testNote2);
      expect(database.notes.length, 2);
      await database.filterNotes('aaa');
      expect(database.notes.single.title, 'AAA');
    });

    test('Detail gets filtered (should not be case sensitive)', () async {
      expect(database.notes.isEmpty, true);
      final testNote1 = Note('Title', 'AAA');
      final testNote2 = Note('Title', 'BBB');
      await database.addNote(testNote1);
      await database.addNote(testNote2);
      expect(database.notes.length, 2);
      await database.filterNotes('aaa');
      expect(database.notes.single.details, 'AAA');
    });

    tearDownAll(() async {
      if (Isar.getInstance() != null) {
        await Isar.getInstance()!.close(deleteFromDisk: true);
      }
    });
  });

  group('Todos database tests', () {
    final database = Database.instance();

    setUpAll(() async {
      if (Isar.getInstance() != null) return;
      Isar.initializeIsarCore(download: true);
      await database.load();
    });

    setUp(() async {
      await database.clearDatabase();
    });

    test('Adding a todo', () async {
      expect(database.todos.isEmpty, true);
      final testTodo = Todo('title', true);
      await database.addTodo(testTodo);
      expect(database.todos.single.id, 1);
      expect(database.todos.single.title, 'title');
      expect(database.todos.single.checked, true);
    });

    test('Removing a todo', () async {
      expect(database.todos.isEmpty, true);
      final testTodo = Todo('title', true);
      await database.addTodo(testTodo);
      expect(database.todos.isNotEmpty, true);
      await database.deleteTodo(testTodo);
      expect(database.todos.isEmpty, true);
    });

    test('Modifying a Todo', () async {
      expect(database.todos.isEmpty, true);
      final testTodo = Todo('title', true);
      await database.addTodo(testTodo);
      expect(database.todos.isNotEmpty, true);
      testTodo.title = 'changedTitle';
      testTodo.checked = false;
      await database.modifyTodo(testTodo);
      expect(database.todos.single.id, 1);
      expect(database.todos.single.title, 'changedTitle');
      expect(database.todos.single.checked, false);
    });

    test('Title gets filtered (should not be case sensitive)', () async {
      expect(database.todos.isEmpty, true);
      final testTodo1 = Todo('AAA', true);
      final testTodo2 = Todo('BBB', false);
      await database.addTodo(testTodo1);
      await database.addTodo(testTodo2);
      expect(database.todos.length, 2);
      await database.filterTodos('aaa');
      expect(database.todos.single.title, 'AAA');
    });

    tearDownAll(() async {
      if (Isar.getInstance() != null) {
        await Isar.getInstance()!.close(deleteFromDisk: true);
      }
    });
  });

  tearDownAll(() async {
    if (Isar.getInstance() != null) {
      await Isar.getInstance()!.close(deleteFromDisk: true);
    }
  });
}
