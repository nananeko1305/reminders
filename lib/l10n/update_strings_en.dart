import 'update_strings.dart';

/// English update strings.
mixin UpdateStringsEn implements UpdateStrings {
  @override
  String get newVersionTitle => 'New version available';
  @override
  String get download => 'Download';
  @override
  String get later => 'Later';
  @override
  String get checkUpdates => 'Check for updates';
  @override
  String get upToDate => 'You have the latest version.';
  @override
  String get updateCheckFailed => "Couldn't check for updates.";

  @override
  String newVersionBody(String version, String current) =>
      'Version $version is ready to download. You have $current.';
  @override
  String appVersion(String version) => 'Version $version';
}
