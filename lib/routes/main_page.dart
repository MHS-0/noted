import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:noted/constants.dart';
import 'package:noted/data/note.dart';
import 'package:noted/data/todo.dart';
import 'package:noted/routes/note_page.dart';
import 'package:noted/routes/settings_page.dart';
import 'package:noted/providers/database.dart';
import 'package:noted/widgets/todo_sheet.dart';
import 'package:provider/provider.dart';

/// The route widget of the Main page.
class MainPage extends StatefulWidget {
  /// The name of this route that gets used in navigation
  static const routeName = '/';

  /// Creates a new Main route for the Noted! app.
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin, RestorationMixin {
  /// The TabController that manages the tabs and it's animations
  late TabController _tabController;

  /// The note route that will be pushed when pressing the FAB in the note's tab
  /// and can be restored. We need this because we need the result data from the route
  late RestorableRouteFuture _restorableNotesRoute;

  /// The TextController for the notes' search TextField
  final _notesSearchController = RestorableTextEditingController();

  /// The TextController for the Todos' search TextField
  final _todosSearchController = RestorableTextEditingController();

  /// The current tab that is being shown. Will be used for FAB's functionality
  final _currentTabIndex = RestorableInt(0);

  /// Set to true when user taps the FAB and false when the user finishes doing so.
  /// Is used for animations
  bool _newEntryBeingMade = false;

  /// Initializes the needed instance variables and sets animation listeners.
  ///
  /// A listener will be added to the [_tabController]'s animation to set the
  /// [_currentTabIndex] to a different index and clear the search fields
  /// if the user is swiping between the tabs, since flutter doesn't change
  /// the TabIndex unless the user taps the TabBar or the swiping animation completes,
  /// which makes the FAB functionality that depends on the current tab, misbehave.
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.animation!.addListener(
      () {
        final value = _tabController.animation!.value.round();
        if (value != _currentTabIndex.value) {
          setState(() =>
              _currentTabIndex.value = _tabController.animation!.value.round());
          switch (_currentTabIndex.value) {
            case 0:
              context.read<Database>().filterTodos(null);
              _todosSearchController.value.clear();
              break;
            default:
              context.read<Database>().filterNotes(null);
              _notesSearchController.value.clear();
          }
        }
      },
    );
    _restorableNotesRoute = RestorableRouteFuture(
      onPresent: (navigator, arguments) => Navigator.restorablePushNamed(
          context, NotePage.routeName,
          arguments: arguments),
      onComplete: (result) => _processNoteRouteResult(result),
    );
  }

  /// Precaches the icon of the app that will be used on the about dialog so that
  /// it doesn't 'pop up' when the dialog gets built for the first time.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(iconAssetPath), context);
  }

  /// The restorationId that will be used to find and restore this route's variables.
  @override
  String? get restorationId => 'Noted Main Route';

  /// restores the state of the app when it gets launched again after getting killed.
  ///
  /// All of the Restorables should be registered here.
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) async {
    registerForRestoration(_currentTabIndex, 'current tab index');
    _tabController.index = _currentTabIndex.value;
    registerForRestoration(_restorableNotesRoute, 'Notes\'s route');
    registerForRestoration(
        _notesSearchController, 'Note tab\'s search controller');
    registerForRestoration(
        _todosSearchController, 'Todo tab\'s search controller');

    // The lists should get filtered after restoration of the search fields are done.
    switch (_currentTabIndex.value) {
      case 0:
        context.read<Database>().filterNotes(_notesSearchController.value.text);
        break;
      default:
        context.read<Database>().filterTodos(_todosSearchController.value.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Listener is used so that the search field can unfocus when the user taps
    // outside of the TextField
    return Listener(
      onPointerDown: (_) {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(localizations.title),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  child: Text(
                localizations.notesTabTitle,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
              )),
              Tab(
                  child: Text(
                localizations.todoTabTitle,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
              )),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNotesTabView(),
            _buildTodoTabView(),
          ],
        ),
        drawer: Drawer(
          child: ListView(children: [
            DrawerHeader(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary),
                child: Center(
                  child: Text(
                    localizations.title,
                    style: const TextStyle(
                      fontSize: 40,
                    ),
                  ),
                )),
            ListTile(
              title: Text(localizations.settings),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.restorablePushNamed(context, SettingsPage.routeName);
              },
              style: ListTileStyle.drawer,
            ),
            const Divider(
              color: Colors.grey,
              indent: 10,
              endIndent: 10,
            ),
            AboutListTile(
              applicationIcon: Image.asset(
                iconAssetPath,
                height: 50,
              ),
              applicationName: localizations.title,
              applicationVersion: localizations.appVersion,
              icon: const Icon(Icons.info),
              aboutBoxChildren: [Text(localizations.aboutDescription)],
            )
          ]),
        ),
        // Wrapped the FAB in an AnimatedPadding instance with bottom viewInsets
        // so that the FAB can animate to the top of the keyboard instead of getting
        // covered by it.
        floatingActionButton: AnimatedPadding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          duration: const Duration(milliseconds: 150),
          child: FloatingActionButton(
            onPressed: () async {
              setState(() {
                _newEntryBeingMade = true;
              });
              if (_currentTabIndex.value == 0) {
                _restorableNotesRoute.present();
              } else if (_currentTabIndex.value == 1) {
                final todo = await showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => const TodoSheet()) as Todo?;
                if (!mounted) return;
                _todosSearchController.value.clear();
                await context.read<Database>().filterTodos('');
                _newEntryBeingMade = false;
                setState(() {});
                if (todo == null) return;
                if (!mounted) return;
                await context.read<Database>().addTodo(todo);
              }
            },
            tooltip: localizations.fabTooltip,
            child: const Icon(Icons.mode_edit_rounded),
          ),
        ),
      ),
    );
  }

  /// Gets called when a note route is completed and may add a note to the notes list.
  /// [noteValues] should be a <String, dynamic> Map containing the keys 'title'
  /// and 'details'. A key 'id' should also be present if the said note was modified.
  void _processNoteRouteResult(Map? noteValues) {
    setState(() {
      _notesSearchController.value.clear();
      context.read<Database>().filterNotes('');
      _newEntryBeingMade = false;
    });
    if (noteValues == null) return;

    // Add if note is modified which is the case if the map has an id key.
    if (!noteValues.containsKey(idKey)) {
      final note = Note(noteValues[titleKey], noteValues[detailsKey]);
      context.read<Database>().addNote(note);
    } else {
      final note = Note(noteValues[titleKey], noteValues[detailsKey])
        ..id = noteValues[idKey];
      context.read<Database>().modifyNote(note);
    }
  }

  /// The notes tab widget
  Consumer<Database> _buildNotesTabView() {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<Database>(builder: (context, value, child) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _notesSearchController.value,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                labelText: localizations.searchFieldLabel,
              ),
              onTap: () {
                value.filterNotes(_notesSearchController.value.text);
              },
              onChanged: (searchValue) {
                value.filterNotes(searchValue);
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _newEntryBeingMade || value.notes.isNotEmpty
                            ? 0
                            : 1,
                        duration: const Duration(milliseconds: 300),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(Icons.event_note_outlined, size: 48),
                              Text(
                                localizations.emptyNoteListText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    restorationId: 'Notes List',
                    itemCount: value.notes.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        key: UniqueKey(),
                        startActionPane: ActionPane(
                          dismissible: DismissiblePane(onDismissed: () {
                            value.deleteNote(value.notes[index]);
                          }),
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) =>
                                  value.deleteNote(value.notes[index]),
                              autoClose: true,
                              label: 'Delete',
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              icon: Icons.delete_outline_rounded,
                            )
                          ],
                        ),
                        child: ListTile(
                          shape: const StadiumBorder(),
                          title: Text(value.notes[index].title),
                          subtitle: Text(
                            value.notes[index].details,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onTap: () async {
                            _restorableNotesRoute.present(<String, dynamic>{
                              idKey: value.notes[index].id,
                              titleKey: value.notes[index].title,
                              detailsKey: value.notes[index].details,
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// The todos tab widget
  Consumer<Database> _buildTodoTabView() {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<Database>(builder: (context, value, child) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _todosSearchController.value,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                labelText: localizations.searchFieldLabel,
              ),
              onChanged: (searchValue) {
                value.filterTodos(searchValue);
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _newEntryBeingMade || value.todos.isNotEmpty
                            ? 0
                            : 1,
                        duration: const Duration(milliseconds: 300),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(Icons.checklist_rounded, size: 48),
                              Text(
                                localizations.emptyTodoListText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    restorationId: 'Todos List',
                    itemCount: value.todos.length,
                    itemBuilder: (context, index) {
                      final checked = value.todos[index].checked;

                      return Slidable(
                        key: ValueKey(value.todos[index].id),
                        startActionPane: ActionPane(
                          dismissible: DismissiblePane(onDismissed: () {
                            value.deleteTodo(value.todos[index]);
                          }),
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) =>
                                  value.deleteTodo(value.todos[index]),
                              autoClose: true,
                              label: 'Delete',
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              icon: Icons.delete_outline_rounded,
                            )
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final todo = await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        TodoSheet(todo: value.todos[index]))
                                as Todo?;
                            if (!mounted) return;
                            if (todo == null) return;
                            await context.read<Database>().modifyTodo(todo);
                          },
                          child: CheckboxListTile(
                            value: checked,
                            onChanged: (isChecked) {
                              value.todos[index].checked = isChecked ?? checked;
                              context
                                  .read<Database>()
                                  .modifyTodo(value.todos[index]);
                            },
                            shape: const StadiumBorder(),
                            title: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeOut,
                              style: checked
                                  ? DefaultTextStyle.of(context).style.copyWith(
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.grey,
                                      )
                                  : DefaultTextStyle.of(context).style,
                              child: Text(
                                value.todos[index].title,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// Dispose of the Controllers and Restorables to avoid memory leak.
  @override
  void dispose() {
    _notesSearchController.dispose();
    _todosSearchController.dispose();
    _restorableNotesRoute.dispose();
    _tabController.dispose();
    _currentTabIndex.dispose();
    super.dispose();
  }
}
