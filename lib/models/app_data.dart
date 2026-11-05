import 'event.dart';

/// Everything the app persists, stored as one JSON blob.
class AppData {
  List<Event> events;

  AppData({required this.events});

  factory AppData.empty() => AppData(events: []);

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        events: (json['events'] as List<dynamic>? ?? [])
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'events': events.map((e) => e.toJson()).toList(),
      };
}
