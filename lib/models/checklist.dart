import 'checklist_item.dart';

/// A named list of things to buy or bring, e.g. "Prodavnica" or "Za put".
class Checklist {
  final String id;
  String name;
  List<ChecklistItem> items;

  Checklist({required this.id, required this.name, List<ChecklistItem>? items})
      : items = items ?? [];

  int get doneCount => items.where((i) => i.done).length;

  factory Checklist.fromJson(Map<String, dynamic> json) => Checklist(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((i) => ChecklistItem.fromJson(i as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'items': items.map((i) => i.toJson()).toList(),
      };
}
