import 'package:flutterweather/l10n/app_localizations.dart';

typedef _Phrase = String Function(AppLocalizations l10n);

/// Each OpenWeatherMap condition code that has its own description.
final Map<int, _Phrase> _byCode = {
  200: (l) => l.condition200,
  201: (l) => l.condition201,
  202: (l) => l.condition202,
  210: (l) => l.condition210,
  211: (l) => l.condition211,
  212: (l) => l.condition212,
  221: (l) => l.condition221,
  230: (l) => l.condition230,
  231: (l) => l.condition231,
  232: (l) => l.condition232,
  300: (l) => l.condition300,
  301: (l) => l.condition301,
  302: (l) => l.condition302,
  310: (l) => l.condition310,
  311: (l) => l.condition311,
  312: (l) => l.condition312,
  313: (l) => l.condition313,
  314: (l) => l.condition314,
  321: (l) => l.condition321,
  500: (l) => l.condition500,
  501: (l) => l.condition501,
  502: (l) => l.condition502,
  503: (l) => l.condition503,
  504: (l) => l.condition504,
  511: (l) => l.condition511,
  520: (l) => l.condition520,
  521: (l) => l.condition521,
  522: (l) => l.condition522,
  531: (l) => l.condition531,
  600: (l) => l.condition600,
  601: (l) => l.condition601,
  602: (l) => l.condition602,
  611: (l) => l.condition611,
  612: (l) => l.condition612,
  613: (l) => l.condition613,
  615: (l) => l.condition615,
  616: (l) => l.condition616,
  620: (l) => l.condition620,
  621: (l) => l.condition621,
  622: (l) => l.condition622,
  701: (l) => l.condition701,
  711: (l) => l.condition711,
  721: (l) => l.condition721,
  731: (l) => l.condition731,
  741: (l) => l.condition741,
  751: (l) => l.condition751,
  761: (l) => l.condition761,
  762: (l) => l.condition762,
  771: (l) => l.condition771,
  781: (l) => l.condition781,
  800: (l) => l.condition800,
  801: (l) => l.condition801,
  802: (l) => l.condition802,
  803: (l) => l.condition803,
  804: (l) => l.condition804,
};

/// The words for an OpenWeatherMap condition code: its own description when it has one, otherwise the group it
/// belongs to (the hundreds), otherwise "Unknown".
String describeCondition(AppLocalizations l10n, int? code) {
  if (code == null) return l10n.conditionUnknown;
  final _Phrase? own = _byCode[code];
  if (own != null) return own(l10n);
  switch (code ~/ 100) {
    case 2:
      return l10n.conditionThunderstorm;
    case 3:
      return l10n.conditionDrizzle;
    case 5:
      return l10n.conditionRain;
    case 6:
      return l10n.conditionSnow;
    case 7:
      return l10n.conditionMist;
    case 8:
      return l10n.conditionClouds;
    default:
      return l10n.conditionUnknown;
  }
}
