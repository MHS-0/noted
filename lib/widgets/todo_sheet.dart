import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:noted/data/todo.dart';

/// The widget that shows when the user attempts to write a new/modify a [Todo] Item.
/// Use with [showModalBottomSheet]. Awaiting the said function while calling this class
/// may result in a new or modified Todo instance being returned.
/// The [todo] parameter can be set to modify an existing instance of Todo.
class TodoSheet extends StatefulWidget {
  /// The [Todo] instance that is getting modified. Set to null for new Todos.
  final Todo? todo;

  const TodoSheet({
    super.key,
    this.todo,
  });

  @override
  State<TodoSheet> createState() => _TodoSheetState();
}

class _TodoSheetState extends State<TodoSheet> {
  /// The localization instance containing tranlations
  late AppLocalizations _localizations;

  /// The TextController assigned to this widget's TextField
  late TextEditingController _todoController;

  /// The title of the [Todo] which will change by typing in the TextField
  late String _title;

  /// The checked state of the [Todo]
  late bool _checked;

  /// Initializes the needed instance variables
  ///
  /// if [Todo] is given to the widget and is thus, not null, [_title] and [checked]
  /// will be assigned to the Todo instance variables. If not, defaults will be given.
  /// [_title] will be set as the TextField's starting text.
  @override
  void initState() {
    super.initState();
    _title = widget.todo?.title ?? '';
    _checked = widget.todo?.checked ?? false;
    _todoController = TextEditingController(text: _title);
  }

  /// Sets the [_localization] variable as it needs context and therefore
  /// can't be initalized in the [initState] method.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizations = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedPadding with bottom viewInsets is used so that when the keyboard is
    // shown, the widget will animate itself to the top of the keyboard instead of
    // being covered by the keyboard.
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(microseconds: 150),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _localizations.todoBottomSheetTitle,
                style: const TextStyle(
                    fontSize: 30, color: Colors.lightBlueAccent),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Checkbox(
                          value: _checked,
                          onChanged: (value) {
                            setState(() {
                              _checked = !_checked;
                            });
                          })),
                  Expanded(
                    flex: 9,
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                        labelText: _localizations.todoTextFieldLabel,
                        hintText: _localizations.todoTextFieldHint,
                      ),
                      autofocus: true,
                      onChanged: (value) => _title = value,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: customButtonStyle(),
                      onPressed: (() => Navigator.pop(context)),
                      child: Text(_localizations.cancelButtonText),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(16)),
                  Expanded(
                    child: TextButton(
                      style: customButtonStyle(),
                      onPressed: (() {
                        if (_title.trim().isEmpty) return;
                        final todo = widget.todo;
                        // if Todo is not given to the widget, return a new Todo
                        // else, modify the existing todo and return it.
                        if (todo == null) {
                          Navigator.pop(context, Todo(_title, _checked));
                        } else {
                          todo.title = _title;
                          todo.checked = _checked;
                          Navigator.pop(context, todo);
                        }
                      }),
                      child: Text(_localizations.saveButtonText),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Style to use for the widget's buttons
  ButtonStyle customButtonStyle() {
    return ButtonStyle(
      fixedSize: WidgetStateProperty.all(const Size.fromHeight(40)),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.pressed)) {
            return const Color.fromARGB(25, 121, 59, 132);
          } else {
            return const Color.fromARGB(25, 121, 59, 132);
          }
        },
      ),
    );
  }
}
