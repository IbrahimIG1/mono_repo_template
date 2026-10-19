import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

final class ShowcaseLocalizations {
  const ShowcaseLocalizations(this.locale);

  static const delegate = _ShowcaseLocalizationsDelegate();
  static const supportedLocales = [Locale('en')];

  final Locale locale;

  static ShowcaseLocalizations of(BuildContext context) =>
      Localizations.of<ShowcaseLocalizations>(context, ShowcaseLocalizations)!;

  String appTitle(String environment) => switch (environment) {
    'production' => 'Showcase',
    'staging' => 'Showcase (Staging)',
    _ => 'Showcase (Development)',
  };

  String bootstrapReady(String environment) =>
      'Bootstrap ready for $environment.';
}

final class _ShowcaseLocalizationsDelegate
    extends LocalizationsDelegate<ShowcaseLocalizations> {
  const _ShowcaseLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<ShowcaseLocalizations> load(Locale locale) =>
      SynchronousFuture(ShowcaseLocalizations(locale));

  @override
  bool shouldReload(_ShowcaseLocalizationsDelegate old) => false;
}
