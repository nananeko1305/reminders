import 'checklist.dart';
import 'event.dart';

/// Everything the app persists, stored as one JSON blob.
class AppData {
  List<Event> events;
  List<Checklist> checklists;

  AppData({required this.events, required this.checklists});

  factory AppData.empty() => AppData(events: [], checklists: []);

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        events: (json['events'] as List<dynamic>? ?? [])
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList(),
        checklists: (json['checklists'] as List<dynamic>? ?? [])
            .map((c) => Checklist.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'events': events.map((e) => e.toJson()).toList(),
        'checklists': checklists.map((c) => c.toJson()).toList(),
      };
}
