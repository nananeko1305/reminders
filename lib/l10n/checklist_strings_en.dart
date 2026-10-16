import 'checklist_strings.dart';

/// English checklist strings.
mixin ChecklistStringsEn implements ChecklistStrings {
  @override
  String get noLists => 'No lists';
  @override
  String get noListsHint => 'Make a list for shopping or a trip';
  @override
  String get newList => 'New list';
  @override
  String get listNameLabel => 'List name';
  @override
  String get listNameHint => 'e.g. Groceries';
  @override
  String get renameList => 'Rename list';
  @override
  String get deleteList => 'Delete list';
  @override
  String get addItemHint => 'Add item…';
  @override
  String get emptyListHint => 'The list is empty — add an item below';
  @override
  String get deleteDone => 'Delete checked';
  @override
  String get uncheckAll => 'Uncheck all';
  @override
  String get itemDeleted => 'Item deleted';

  @override
  String deleteListMsg(String name) =>
      'The list "$name" and all its items will be deleted.';
}
