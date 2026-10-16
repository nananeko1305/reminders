/// One line of a checklist, such as "mleko" in "Prodavnica".
class ChecklistItem {
  final String id;
  String text;
  bool done;

  ChecklistItem({required this.id, required this.text, this.done = false});

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String,
        text: json['text'] as String? ?? '',
        done: json['done'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'done': done};
}
