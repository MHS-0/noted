import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:noted/data/note.dart';

const idKey = 'id';
const titleKey = 'title';
const detailsKey = 'detials';

/// The route widget of the Note page. Awaiting this route may result in a new or modified instance
/// of [Note]. The [noteValues] parameter can be set if an existing note is being modified.
class NotePage extends StatefulWidget {
  /// The name of this route that gets used in navigation
  static const routeName = 'note';

  /// The values of the note that is being modified. It is a map because state restoration
  /// doesn't work for values that are not primitive, for example, an instance of Note.
  /// This map should be of type <String, dynamic> just like a Json file. it is not
  /// typed here because it causes issues in the Dart VM's when attempting state restoration.
  /// It should have the keys: 'id', 'title' and 'details' each assigned to the related
  /// [Note]'s instance variables.
  ///
  /// Set to null for a new note.
  final Map? noteValues;

  /// Creates a new Note route. Set the [noteValues] to modify a note or leave it
  /// as null to add a new one.
  const NotePage({super.key, this.noteValues});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with RestorationMixin {
  /// The textController for the title's TextField
  late RestorableTextEditingController _titleController;

  /// The textController for the details' TextField
  late RestorableTextEditingController _detailsController;

  /// Initializes the needed instance variables
  ///
  /// if [noteValues] is given to the widget, the default values
  /// of the TextControllers will be assigned to the given values.
  @override
  void initState() {
    super.initState();
    _titleController =
        RestorableTextEditingController(text: widget.noteValues?[titleKey]);
    _detailsController =
        RestorableTextEditingController(text: widget.noteValues?[detailsKey]);
  }

  /// The restorationId that will be used to find and restore this route's variables.
  @override
  String? get restorationId => 'Note Route';

  /// restores the state of the app when it gets launched again after getting killed.
  ///
  /// All of the Restorables should be registered here.
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_titleController, 'Title input controller');
    registerForRestoration(_detailsController, 'Details input controller');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // WillPopScope is used so that when the user pop's the route and returns,
    // the result can be processed and returned. It also supports the Android's back button.
    return WillPopScope(
      onWillPop: () async {
        var title = _titleController.value.text;
        var details = _detailsController.value.text;
        final noteValues = widget.noteValues;

        if (title.trim().isEmpty && details.trim().isEmpty) {
          Navigator.pop(context, null);
          return true;
        }

        if (noteValues == null) {
          if (title.trim().isEmpty) {
            final firstDetailsLine = LineSplitter.split(details).first;
            if (firstDetailsLine.length <= 36) {
              title = firstDetailsLine;
            } else {
              title = firstDetailsLine.substring(0, 36);
            }
          }
          final newNoteValues = <String, dynamic>{
            titleKey: title,
            detailsKey: details,
          };
          Navigator.pop(context, newNoteValues);
        } else {
          noteValues[titleKey] = title;
          noteValues[detailsKey] = details;
          Navigator.pop(context, noteValues);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController.value,
                decoration: InputDecoration(
                  labelText: localizations.titleTextFieldLabel,
                  hintText: localizations.titleTextFieldHint,
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                child: TextField(
                  controller: _detailsController.value,
                  decoration: InputDecoration(
                    labelText: localizations.detailsTextFieldLabel,
                    hintText: localizations.detailsTextFieldHint,
                  ),
                  autofocus: true,
                  maxLines: null,
                  minLines: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dispose of the RestorableTextControllers so that memory leak doesn't happen.
  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
}
