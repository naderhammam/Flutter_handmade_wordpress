import 'package:nylo_framework/nylo_framework.dart';


final LocaleType localeType = LocaleType.asDefined; // device, asDefined

final String? languageCode = getEnv('DEFAULT_LOCALE', defaultValue: "en");


final List<String> languagesList = const [
  'en',
  'es',
  'fr',
  'hi',
  'it',
  'pt',
  'zh'
];


final String assetsDirectory = 'lang/';


final Map<String, String> valuesAsMap = {};
