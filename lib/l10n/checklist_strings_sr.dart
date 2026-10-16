import 'checklist_strings.dart';

/// Serbian (Latin) checklist strings.
mixin ChecklistStringsSr implements ChecklistStrings {
  @override
  String get noLists => 'Nema lista';
  @override
  String get noListsHint => 'Napravi listu za prodavnicu ili put';
  @override
  String get newList => 'Nova lista';
  @override
  String get listNameLabel => 'Naziv liste';
  @override
  String get listNameHint => 'npr. Prodavnica';
  @override
  String get renameList => 'Preimenuj listu';
  @override
  String get deleteList => 'Obriši listu';
  @override
  String get addItemHint => 'Dodaj stavku…';
  @override
  String get emptyListHint => 'Lista je prazna — dodaj stavku ispod';
  @override
  String get deleteDone => 'Obriši označene';
  @override
  String get uncheckAll => 'Poništi sve';
  @override
  String get itemDeleted => 'Stavka obrisana';

  @override
  String deleteListMsg(String name) =>
      'Lista „$name" i sve njene stavke biće obrisane.';
}
