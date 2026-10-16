import 'checklist_strings_sr.dart';
import 'event_strings_sr.dart';
import 'strings.dart';
import 'update_strings_sr.dart';

/// Serbian (Latin) translations.
class StringsSr extends AppStrings
    with EventStringsSr, ChecklistStringsSr, UpdateStringsSr {
  const StringsSr();

  @override
  String get localeCode => 'sr';
  @override
  String get navEvents => 'Podsetnici';
  @override
  String get navLists => 'Liste';
  @override
  String get save => 'Sačuvaj';
  @override
  String get cancel => 'Otkaži';
  @override
  String get delete => 'Obriši';
  @override
  String get rename => 'Preimenuj';
  @override
  String get undo => 'Vrati';
  @override
  String get settings => 'Podešavanja';
  @override
  String get language => 'Jezik';
  @override
  String get theme => 'Tema';
  @override
  String get themeSystem => 'Sistem';
  @override
  String get themeLight => 'Svetla';
  @override
  String get themeDark => 'Tamna';
  @override
  String get notificationsSection => 'Zvono i notifikacije';
  @override
  String get permNotifications => 'Notifikacije';
  @override
  String get permExactAlarms => 'Tačni alarmi';
  @override
  String get permFullScreen => 'Alarm preko celog ekrana';
  @override
  String get permFullScreenHint =>
      'Potrebno da alarm upali ekran kad je telefon zaključan (Android 14+).';
  @override
  String get permAllowed => 'Dozvoljeno';
  @override
  String get permMissing => 'Nije dozvoljeno';
  @override
  String get permFix => 'Podesi';
  @override
  String get testAlarm => 'Test alarm (za 10 s)';
  @override
  String get testAlarmScheduled =>
      'Alarm stiže za 10 sekundi — zaključaj telefon da probaš.';
  @override
  String get batteryHint =>
      'Ako alarm kasni ili ne zvoni, isključi optimizaciju baterije za ovu aplikaciju.';

  @override
  List<String> get weekdayNames => const [
        'Ponedeljak',
        'Utorak',
        'Sreda',
        'Četvrtak',
        'Petak',
        'Subota',
        'Nedelja',
      ];

  @override
  List<String> get monthShortNames => const [
        'jan', 'feb', 'mar', 'apr', 'maj', 'jun', //
        'jul', 'avg', 'sep', 'okt', 'nov', 'dec',
      ];

  @override
  String get nowLabel => 'sada';

  @override
  String inMinutes(int minutes) => 'za $minutes min';

  @override
  String inHours(int hours, int minutes) =>
      minutes == 0 ? 'za $hours h' : 'za $hours h $minutes min';

  @override
  String inDays(int days) => 'za $days ${_dana(days)}';

  @override
  String shortDate(DateTime d) => '${d.day}. ${monthShortNames[d.month - 1]}';

  @override
  String longDate(DateTime d) => '${weekday(d)}, ${shortDate(d)} ${d.year}.';

  /// 1, 21, 31… → "dan"; everything else (incl. 11) → "dana".
  static String _dana(int n) => n % 10 == 1 && n % 100 != 11 ? 'dan' : 'dana';
}
