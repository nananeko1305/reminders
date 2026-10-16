import 'update_strings.dart';

/// Serbian (Latin) update strings.
mixin UpdateStringsSr implements UpdateStrings {
  @override
  String get newVersionTitle => 'Dostupna je nova verzija';
  @override
  String get download => 'Preuzmi';
  @override
  String get later => 'Kasnije';
  @override
  String get checkUpdates => 'Proveri ažuriranja';
  @override
  String get upToDate => 'Imaš najnoviju verziju.';
  @override
  String get updateCheckFailed => 'Provera ažuriranja nije uspela.';

  @override
  String newVersionBody(String version, String current) =>
      'Verzija $version je spremna za preuzimanje. Ti imaš $current.';
  @override
  String appVersion(String version) => 'Verzija $version';
}
