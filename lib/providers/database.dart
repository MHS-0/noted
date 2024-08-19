import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:noted/data/note.dart';
import 'package:noted/data/todo.dart';
import 'package:path_provider/path_provider.dart';

/// This provider class manages the Isar database instance which holds the
/// user's notes and todos and notifies the listeners of the changes
/// made in those databases. The load method should be called and awaited before this
/// class can be used.
class Database with ChangeNotifier {
  /// Private constructor to use when instantiating an instance inside the file.
  Database._privateConstructor();

  /// The singleton instance of this class
  static final Database _storage = Database._privateConstructor();

  /// The Isar database instance
  late Isar _database;

  /// The list containing all the user's notes
  late List<Note> _notes;

  /// The list containing all the user's todos.
  late List<Todo> _todos;

  /// The list containing all the user's notes. Don't change the list directly.
  /// Use the given methods instead.
  List<Note> get notes => _notes.reversed.toList();

  /// The list containing all the user's todos. Don't change the list directly.
  /// Use the given methods instead.
  List<Todo> get todos => _todos.reversed.toList();

  /// Loads the Isar database instance and assigns the necessary variables. Should
  /// be called and awaited before the instance can be used.
  Future<void> load() async {
    if (Isar.getInstance() != null) return;
    // Retreive the current saved notes and TODOs.
    final dir = await getApplicationSupportDirectory();
    _database = await Isar.open([NoteSchema, TodoSchema], directory: dir.path);
    _notes = await _database.notes.where().findAll();
    _todos = await _database.todos.where().findAll();
  }

  /// Clears the database of all the notes and todos. Used mainly for testing.
  Future<void> clearDatabase() async {
    await _database.writeTxn(() async => await _database.notes.clear());
    _notes = [];
    await _database.writeTxn(() async => await _database.todos.clear());
    _todos = [];
  }

  /// Adds a new note and saves it in the database. [note] is the instance of [Note]
  /// that will be added.
  Future<void> addNote(Note note) async {
    await _database.writeTxn(() async => await _database.notes.put(note));
    _notes = await _database.notes.where().findAll();
    notifyListeners();
  }

  /// Modifies a note and saves it in the database. [note] is the instance of [Note]
  /// that will be modified.
  Future<void> modifyNote(Note note) async {
    await _database.writeTxn(() async => await _database.notes.put(note));
    _notes = await _database.notes.where().findAll();
    notifyListeners();
  }

  /// Deletes a note and removes it from the database.
  Future<void> deleteNote(Note note) async {
    if (note.id == null) return;
    await _database
        .writeTxn(() async => await _database.notes.delete(note.id!));
    _notes = await _database.notes.where().findAll();
    notifyListeners();
  }

  /// Filters the notes so that only the notes containing the [searchValue] are shown.
  Future<void> filterNotes(String? searchValue) async {
    if (searchValue == null || searchValue.isEmpty) {
      _notes = await _database.notes.where().findAll();
      notifyListeners();
      return;
    }
    final filteredNotes = await _database.notes
        .filter()
        .titleContains(searchValue, caseSensitive: false)
        .or()
        .detailsContains(searchValue, caseSensitive: false)
        .findAll();
    _notes = filteredNotes;
    notifyListeners();
  }

  /// Adds a new todo and saves it in the database. [todo] is the instance of [Todo]
  /// that will be added.
  Future<void> addTodo(Todo todo) async {
    await _database.writeTxn(() async => await _database.todos.put(todo));
    _todos = await _database.todos.where().findAll();
    notifyListeners();
  }

  /// Modifies a note and saves it in the database.
  Future<void> modifyTodo(Todo todo) async {
    await _database.writeTxn(() async => await _database.todos.put(todo));
    _todos = await _database.todos.where().findAll();
    notifyListeners();
  }

  /// Deletes a note and removes it from the database.
  Future<void> deleteTodo(Todo todo) async {
    if (todo.id == null) return;
    await _database
        .writeTxn(() async => await _database.todos.delete(todo.id!));
    _todos = await _database.todos.where().findAll();
    notifyListeners();
  }

  /// Filters the todos so that only the todos containing the [searchValue] are shown.
  Future<void> filterTodos(String? searchValue) async {
    if (searchValue == null || searchValue.isEmpty) {
      _todos = await _database.todos.where().findAll();
      notifyListeners();
      return;
    }
    final filteredTodos = await _database.todos
        .filter()
        .titleContains(searchValue, caseSensitive: false)
        .findAll();
    _todos = filteredTodos;
    notifyListeners();
  }

  /// The factory that returns the singleton instance.
  factory Database.instance() => _storage;
}
