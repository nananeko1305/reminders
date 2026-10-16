import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/checklist.dart';
import '../theme.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import 'checklist_screen.dart';

/// All checklists with their progress. Tap to open, long-press for options.
class ChecklistsScreen extends StatefulWidget {
  const ChecklistsScreen({super.key});

  @override
  State<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends State<ChecklistsScreen> {
  List<Checklist>? _lists;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    final lists = await AppScope.of(context).services.checklists.lists();
    if (mounted) setState(() => _lists = lists);
  }

  Future<void> _create() async {
    final scope = AppScope.of(context);
    final s = scope.strings;
    final name = await showNameDialog(context,
        title: s.newList, label: s.listNameLabel, hint: s.listNameHint);
    if (name == null) return;
    final list = await scope.services.checklists.addList(name);
    await _open(list);
  }

  Future<void> _open(Checklist list) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ChecklistScreen(listId: list.id)),
    );
    await _reload();
  }

  Future<void> _rename(Checklist list) async {
    final scope = AppScope.of(context);
    final s = scope.strings;
    final name = await showNameDialog(context,
        title: s.renameList, label: s.listNameLabel, initial: list.name);
    if (name == null) return;
    await scope.services.checklists.renameList(list.id, name);
    await _reload();
  }

  Future<void> _delete(Checklist list) async {
    final scope = AppScope.of(context);
    final ok = await showConfirmDialog(context,
        title: scope.strings.deleteList,
        message: scope.strings.deleteListMsg(list.name));
    if (!ok) return;
    await scope.services.checklists.deleteList(list.id);
    await _reload();
  }

  Future<void> _options(Checklist list) async {
    final s = AppScope.of(context).strings;
    final action = await showModalBottomSheet<VoidCallback>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(s.renameList),
              onTap: () => Navigator.pop(context, () => _rename(list)),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: palette(context).alarm),
              title: Text(s.deleteList),
              onTap: () => Navigator.pop(context, () => _delete(list)),
            ),
          ],
        ),
      ),
    );
    action?.call();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    final lists = _lists;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'lists-fab',
        onPressed: _create,
        tooltip: s.newList,
        child: const Icon(Icons.playlist_add),
      ),
      body: switch (lists) {
        null => const Center(child: CircularProgressIndicator()),
        [] => EmptyState(
            icon: Icons.checklist, title: s.noLists, hint: s.noListsHint),
        _ => ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            children: [for (final list in lists) _card(list)],
          ),
      },
    );
  }

  Widget _card(Checklist list) {
    final s = AppScope.of(context).strings;
    final p = palette(context);
    final total = list.items.length;
    final done = list.doneCount;
    return Card(
      child: ListTile(
        onTap: () => _open(list),
        onLongPress: () => _options(list),
        leading: Icon(
          total > 0 && done == total ? Icons.task_alt : Icons.checklist,
          color: p.brand,
        ),
        title: Text(list.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : done / total,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        trailing: Text(s.progress(done, total),
            style: TextStyle(color: p.muted)),
      ),
    );
  }
}
