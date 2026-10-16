import '../models/app_data.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import 'app_data_store.dart';
import 'id_generator.dart';

/// CRUD for checklists and their items.
class ChecklistRepository {
  ChecklistRepository({required this._store, IdGenerator? ids})
      : _ids = ids ?? IdGenerator();

  final AppDataStore _store;
  final IdGenerator _ids;

  Future<List<Checklist>> lists() async => (await _store.read()).checklists;

  Future<Checklist?> byId(String id) async =>
      _find(await _store.read(), id);

  Future<Checklist> addList(String name) {
    final list = Checklist(id: _ids.next(), name: name.trim());
    return _store.update((data) {
      data.checklists.add(list);
      return list;
    });
  }

  Future<void> renameList(String id, String name) =>
      _edit(id, (list) => list.name = name.trim());

  Future<void> deleteList(String id) => _store
      .update((data) => data.checklists.removeWhere((c) => c.id == id));

  Future<void> addItem(String listId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Future.value();
    return _edit(listId,
        (list) => list.items.add(ChecklistItem(id: _ids.next(), text: trimmed)));
  }

  /// Puts back an item removed with [deleteItem] (for "undo").
  Future<void> restoreItem(String listId, ChecklistItem item, int index) =>
      _edit(listId,
          (list) => list.items.insert(index.clamp(0, list.items.length), item));

  Future<void> toggleItem(String listId, String itemId) => _edit(listId, (list) {
        for (final item in list.items) {
          if (item.id == itemId) item.done = !item.done;
        }
      });

  Future<void> deleteItem(String listId, String itemId) =>
      _edit(listId, (list) => list.items.removeWhere((i) => i.id == itemId));

  Future<void> deleteDone(String listId) =>
      _edit(listId, (list) => list.items.removeWhere((i) => i.done));

  /// Unchecks every item, to reuse a list such as "Za put".
  Future<void> uncheckAll(String listId) => _edit(listId, (list) {
        for (final item in list.items) {
          item.done = false;
        }
      });

  Future<void> _edit(String listId, void Function(Checklist list) change) =>
      _store.update((data) {
        final list = _find(data, listId);
        if (list != null) change(list);
      });

  static Checklist? _find(AppData data, String id) {
    for (final c in data.checklists) {
      if (c.id == id) return c;
    }
    return null;
  }
}
