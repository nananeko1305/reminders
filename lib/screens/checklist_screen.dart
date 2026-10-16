import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../theme.dart';
import '../widgets/checklist_item_tile.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import '../widgets/quick_add_field.dart';

enum _MenuAction { rename, uncheckAll, deleteDone, deleteList }

/// One checklist: tap to check (strike-through), swipe to delete with undo,
/// quick-add at the bottom.
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key, required this.listId});

  final String listId;

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final _scroll = ScrollController();
  Checklist? _list;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final list = await AppScope.of(context).services.checklists.byId(widget.listId);
    if (mounted) setState(() => _list = list);
  }

  /// Runs a repository change, then shows the result.
  Future<void> _change(Future<void> Function() action) async {
    await action();
    await _reload();
  }

  Future<void> _add(String text) async {
    final repo = AppScope.of(context).services.checklists;
    await _change(() => repo.addItem(widget.listId, text));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  void _delete(ChecklistItem item, int index) {
    final scope = AppScope.of(context);
    final repo = scope.services.checklists;
    setState(() => _list?.items.removeAt(index));
    repo.deleteItem(widget.listId, item.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(scope.strings.itemDeleted),
        action: SnackBarAction(
          label: scope.strings.undo,
          onPressed: () =>
              _change(() => repo.restoreItem(widget.listId, item, index)),
        ),
      ));
  }

  Future<void> _onMenu(_MenuAction action) async {
    final scope = AppScope.of(context);
    final s = scope.strings;
    final repo = scope.services.checklists;
    final list = _list!;
    switch (action) {
      case _MenuAction.rename:
        final name = await showNameDialog(context,
            title: s.renameList, label: s.listNameLabel, initial: list.name);
        if (name != null) await _change(() => repo.renameList(list.id, name));
      case _MenuAction.uncheckAll:
        await _change(() => repo.uncheckAll(list.id));
      case _MenuAction.deleteDone:
        await _change(() => repo.deleteDone(list.id));
      case _MenuAction.deleteList:
        final ok = await showConfirmDialog(context,
            title: s.deleteList, message: s.deleteListMsg(list.name));
        if (!ok) return;
        await repo.deleteList(list.id);
        if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    final list = _list;
    if (list == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
        actions: [
          Center(child: Text(s.progress(list.doneCount, list.items.length))),
          PopupMenuButton<_MenuAction>(
            onSelected: _onMenu,
            itemBuilder: (_) => [
              PopupMenuItem(value: _MenuAction.rename, child: Text(s.renameList)),
              PopupMenuItem(value: _MenuAction.uncheckAll, child: Text(s.uncheckAll)),
              PopupMenuItem(value: _MenuAction.deleteDone, child: Text(s.deleteDone)),
              PopupMenuItem(value: _MenuAction.deleteList, child: Text(s.deleteList)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: list.items.isEmpty
                ? EmptyState(
                    icon: Icons.playlist_add_check,
                    title: list.name,
                    hint: s.emptyListHint)
                : ListView.builder(
                    controller: _scroll,
                    itemCount: list.items.length,
                    itemBuilder: (context, i) => _itemRow(list, i),
                  ),
          ),
          QuickAddField(hint: s.addItemHint, onAdd: _add),
        ],
      ),
    );
  }

  Widget _itemRow(Checklist list, int index) {
    final item = list.items[index];
    final repo = AppScope.of(context).services.checklists;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(item, index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete_outline, color: palette(context).alarm),
      ),
      child: ChecklistItemTile(
        item: item,
        onToggle: () => _change(() => repo.toggleItem(list.id, item.id)),
      ),
    );
  }
}
