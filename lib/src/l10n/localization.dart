/// Localization configuration and utilities.
///
/// Provides infrastructure for internationalization including
/// locale management, date/number formatting, and RTL support.
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'translations.dart';

/// Supported locales.
class AppLocales {
  AppLocales._();

  /// English (US)
  static const Locale en = Locale('en', 'US');

  /// Turkish
  static const Locale tr = Locale('tr', 'TR');

  /// German
  static const Locale de = Locale('de', 'DE');

  /// French
  static const Locale fr = Locale('fr', 'FR');

  /// Spanish
  static const Locale es = Locale('es', 'ES');

  /// List of all supported locales.
  static const List<Locale> supportedLocales = [en, tr, de, fr, es];

  /// Default locale.
  static const Locale defaultLocale = en;

  /// RTL locales.
  static const List<String> rtlLanguages = ['ar', 'he', 'fa', 'ur'];

  /// Checks if a locale is RTL.
  static bool isRtl(Locale locale) {
    return rtlLanguages.contains(locale.languageCode);
  }
}

/// App localizations delegate.
class AppLocalizations {
  /// Creates a new [AppLocalizations] instance.
  AppLocalizations(this.locale);

  /// The current locale.
  final Locale locale;

  /// Gets the localization instance from context.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// The delegate for loading localizations.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Supported locales.
  static List<Locale> get supportedLocales => AppLocales.supportedLocales;

  late final Translations _translations = Translations.forLocale(locale);

  /// Gets a translation by key.
  String translate(String key, [Map<String, dynamic>? params]) {
    var text = _translations.get(key);
    if (params != null) {
      params.forEach((paramKey, value) {
        text = text.replaceAll('{$paramKey}', value.toString());
      });
    }
    return text;
  }

  /// Gets plural form.
  String plural(String key, int count, [Map<String, dynamic>? params]) {
    final baseKey = count == 1 ? '${key}_one' : '${key}_other';
    final finalParams = {...?params, 'count': count};
    return translate(baseKey, finalParams);
  }

  // Common translations
  /// App name.
  String get appName => translate('app_name');

  /// OK button.
  String get ok => translate('ok');

  /// Cancel button.
  String get cancel => translate('cancel');

  /// Save button.
  String get save => translate('save');

  /// Delete button.
  String get delete => translate('delete');

  /// Edit button.
  String get edit => translate('edit');

  /// Close button.
  String get close => translate('close');

  /// Done button.
  String get done => translate('done');

  /// Loading text.
  String get loading => translate('loading');

  /// Error text.
  String get error => translate('error');

  /// Success text.
  String get success => translate('success');

  /// Retry button.
  String get retry => translate('retry');

  /// Search hint.
  String get search => translate('search');

  /// Empty state message.
  String get empty => translate('empty');

  /// No results message.
  String get noResults => translate('no_results');

  /// Settings title.
  String get settings => translate('settings');

  /// Profile title.
  String get profile => translate('profile');

  /// Home title.
  String get home => translate('home');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocales.supportedLocales
        .any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Locale service for managing app locale.
class LocaleService {
  /// Creates a new [LocaleService].
  LocaleService();

  Locale _currentLocale = AppLocales.defaultLocale;

  /// The current locale.
  Locale get currentLocale => _currentLocale;

  /// Whether the current locale is RTL.
  bool get isRtl => AppLocales.isRtl(_currentLocale);

  /// Sets the current locale.
  void setLocale(Locale locale) {
    if (AppLocales.supportedLocales.contains(locale)) {
      _currentLocale = locale;
    }
  }

  /// Gets locale from language code.
  Locale? getLocaleFromCode(String code) {
    return AppLocales.supportedLocales.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => AppLocales.defaultLocale,
    );
  }
}

/// Date formatting utilities.
class DateFormatter {
  DateFormatter._();

  /// Formats a date as short date (e.g., "Jan 1, 2024").
  static String shortDate(DateTime date, [Locale? locale]) {
    final formatter = DateFormat.yMMMd(locale?.languageCode ?? 'en');
    return formatter.format(date);
  }

  /// Formats a date as long date (e.g., "January 1, 2024").
  static String longDate(DateTime date, [Locale? locale]) {
    final formatter = DateFormat.yMMMMd(locale?.languageCode ?? 'en');
    return formatter.format(date);
  }

  /// Formats a time (e.g., "3:30 PM").
  static String time(DateTime date, [Locale? locale]) {
    final formatter = DateFormat.jm(locale?.languageCode ?? 'en');
    return formatter.format(date);
  }

  /// Formats date and time.
  static String dateTime(DateTime date, [Locale? locale]) {
    final formatter = DateFormat.yMMMd(locale?.languageCode ?? 'en')
        .add_jm();
    return formatter.format(date);
  }

  /// Formats as relative time (e.g., "2 hours ago").
  static String relative(DateTime date, [Locale? locale]) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return longDate(date, locale);
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

/// Number formatting utilities.
class NumberFormatter {
  NumberFormatter._();

  /// Formats a number with locale-specific grouping.
  static String format(num number, [Locale? locale]) {
    final formatter = NumberFormat.decimalPattern(locale?.languageCode ?? 'en');
    return formatter.format(number);
  }

  /// Formats as currency.
  static String currency(
    num amount, {
    String symbol = '\$',
    Locale? locale,
    int decimalDigits = 2,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale?.languageCode ?? 'en',
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Formats as percentage.
  static String percent(num value, [Locale? locale]) {
    final formatter = NumberFormat.percentPattern(locale?.languageCode ?? 'en');
    return formatter.format(value);
  }

  /// Formats as compact (e.g., "1.2K", "3.4M").
  static String compact(num number, [Locale? locale]) {
    final formatter = NumberFormat.compact(locale: locale?.languageCode ?? 'en');
    return formatter.format(number);
  }
}
