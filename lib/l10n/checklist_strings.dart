/// Strings for the checklists section. Mixed into [AppStrings]; each language
/// implements it in its own file.
mixin ChecklistStrings {
  String get noLists;
  String get noListsHint;
  String get newList;
  String get listNameLabel;
  String get listNameHint;
  String get renameList;
  String get deleteList;
  String get addItemHint;
  String get emptyListHint;
  String get deleteDone;
  String get uncheckAll;
  String get itemDeleted;

  String deleteListMsg(String name);
}
