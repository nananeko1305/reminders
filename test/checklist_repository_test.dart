import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reminders/services/app_data_store.dart';
import 'package:reminders/services/checklist_repository.dart';

void main() {
  late ChecklistRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = ChecklistRepository(store: AppDataStore());
  });

  Future<List<String>> texts(String listId) async =>
      (await repo.byId(listId))!.items.map((i) => i.text).toList();

  test('lists and items are stored, blanks ignored', () async {
    final list = await repo.addList(' Prodavnica ');
    await repo.addItem(list.id, 'mleko');
    await repo.addItem(list.id, '   ');
    await repo.addItem(list.id, ' hleb ');

    expect((await repo.lists()).single.name, 'Prodavnica');
    expect(await texts(list.id), ['mleko', 'hleb']);
  });

  test('toggle, delete checked, uncheck all', () async {
    final list = await repo.addList('Za put');
    await repo.addItem(list.id, 'pasoš');
    await repo.addItem(list.id, 'punjač');
    await repo.addItem(list.id, 'četkica');
    final items = (await repo.byId(list.id))!.items;

    await repo.toggleItem(list.id, items[0].id);
    await repo.toggleItem(list.id, items[1].id);
    expect((await repo.byId(list.id))!.doneCount, 2);

    await repo.uncheckAll(list.id);
    expect((await repo.byId(list.id))!.doneCount, 0);

    await repo.toggleItem(list.id, items[1].id);
    await repo.deleteDone(list.id);
    expect(await texts(list.id), ['pasoš', 'četkica']);
  });

  test('restoreItem puts a deleted item back in its place', () async {
    final list = await repo.addList('L');
    for (final t in ['a', 'b', 'c']) {
      await repo.addItem(list.id, t);
    }
    final b = (await repo.byId(list.id))!.items[1];
    await repo.deleteItem(list.id, b.id);
    expect(await texts(list.id), ['a', 'c']);

    await repo.restoreItem(list.id, b, 1);
    expect(await texts(list.id), ['a', 'b', 'c']);
  });

  test('rename and delete list', () async {
    final list = await repo.addList('Stara');
    await repo.renameList(list.id, 'Nova');
    expect((await repo.lists()).single.name, 'Nova');

    await repo.deleteList(list.id);
    expect(await repo.lists(), isEmpty);
  });

  test('concurrent edits never overwrite each other', () async {
    final list = await repo.addList('L');
    await Future.wait([
      for (var i = 0; i < 10; i++) repo.addItem(list.id, 'item $i'),
    ]);
    expect(await texts(list.id), hasLength(10));
  });
}
