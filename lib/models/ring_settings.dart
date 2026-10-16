import 'ring_mode.dart';

/// A sound from the phone (ringtone, alarm or notification sound) picked in
/// the system picker. [uri] null means the phone's default alarm sound.
class AlarmSound {
  final String? uri;

  /// Name shown in Settings; null for the default sound or when unknown.
  final String? title;

  const AlarmSound({this.uri, this.title});

  static const phoneDefault = AlarmSound();

  bool get isDefault => uri == null;
}

/// Everything that decides how reminders ring. One setting for all events.
class RingSettings {
  final RingMode mode;

  /// Plays at the event time (alarm or notification mode); earlier reminders
  /// keep the short notification sound.
  final AlarmSound sound;

  /// Whether the alarm turns the screen on over the lock screen. Off, it
  /// still rings until dismissed, as a heads-up notification.
  final bool fullScreen;

  const RingSettings({
    this.mode = RingMode.alarm,
    this.sound = AlarmSound.phoneDefault,
    this.fullScreen = true,
  });

  RingSettings copyWith({RingMode? mode, AlarmSound? sound, bool? fullScreen}) =>
      RingSettings(
        mode: mode ?? this.mode,
        sound: sound ?? this.sound,
        fullScreen: fullScreen ?? this.fullScreen,
      );
}
