/// Strings for "new version available" (release push + update check). Mixed
/// into [AppStrings]; each language implements it in its own file.
mixin UpdateStrings {
  String get newVersionTitle;
  String get download;
  String get later;
  String get checkUpdates;
  String get upToDate;
  String get updateCheckFailed;

  String newVersionBody(String version, String current);
  String appVersion(String version);
}
