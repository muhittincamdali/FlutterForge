/// Translation strings for the application.
///
/// Contains all translatable strings organized by language.
library;

import 'package:flutter/material.dart';

/// Translation container class.
class Translations {
  /// Creates a [Translations] instance for the given locale.
  factory Translations.forLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return Translations._(_trTranslations);
      case 'de':
        return Translations._(_deTranslations);
      case 'fr':
        return Translations._(_frTranslations);
      case 'es':
        return Translations._(_esTranslations);
      case 'en':
      default:
        return Translations._(_enTranslations);
    }
  }

  Translations._(this._translations);

  final Map<String, String> _translations;

  /// Gets a translation by key.
  String get(String key) {
    return _translations[key] ?? _enTranslations[key] ?? key;
  }

  /// Checks if a key exists.
  bool has(String key) {
    return _translations.containsKey(key);
  }
}

/// English translations.
const Map<String, String> _enTranslations = {
  // App
  'app_name': 'FlutterForge',

  // Common actions
  'ok': 'OK',
  'cancel': 'Cancel',
  'save': 'Save',
  'delete': 'Delete',
  'edit': 'Edit',
  'close': 'Close',
  'done': 'Done',
  'retry': 'Retry',
  'search': 'Search',
  'continue': 'Continue',
  'back': 'Back',
  'next': 'Next',
  'skip': 'Skip',
  'submit': 'Submit',
  'confirm': 'Confirm',
  'yes': 'Yes',
  'no': 'No',

  // Status
  'loading': 'Loading...',
  'error': 'Error',
  'success': 'Success',
  'warning': 'Warning',
  'info': 'Info',

  // Empty states
  'empty': 'No data available',
  'no_results': 'No results found',
  'no_items': 'No items',

  // Navigation
  'home': 'Home',
  'settings': 'Settings',
  'profile': 'Profile',
  'notifications': 'Notifications',
  'help': 'Help',
  'about': 'About',

  // Auth
  'login': 'Log In',
  'logout': 'Log Out',
  'register': 'Register',
  'sign_up': 'Sign Up',
  'forgot_password': 'Forgot Password?',
  'reset_password': 'Reset Password',
  'email': 'Email',
  'password': 'Password',
  'confirm_password': 'Confirm Password',
  'username': 'Username',

  // Validation
  'required_field': 'This field is required',
  'invalid_email': 'Please enter a valid email',
  'password_too_short': 'Password must be at least 8 characters',
  'passwords_dont_match': 'Passwords do not match',

  // Errors
  'generic_error': 'Something went wrong',
  'network_error': 'Network error. Please check your connection.',
  'server_error': 'Server error. Please try again later.',
  'unauthorized': 'You are not authorized to perform this action',
  'not_found': 'Not found',
  'timeout': 'Request timed out',

  // Confirmations
  'delete_confirmation': 'Are you sure you want to delete this?',
  'logout_confirmation': 'Are you sure you want to log out?',
  'unsaved_changes': 'You have unsaved changes. Discard them?',

  // Time
  'today': 'Today',
  'yesterday': 'Yesterday',
  'tomorrow': 'Tomorrow',
  'just_now': 'Just now',
  'minutes_ago': '{count} minutes ago',
  'hours_ago': '{count} hours ago',
  'days_ago': '{count} days ago',

  // Plurals
  'item_one': '{count} item',
  'item_other': '{count} items',
  'notification_one': '{count} notification',
  'notification_other': '{count} notifications',
};

/// Turkish translations.
const Map<String, String> _trTranslations = {
  // App
  'app_name': 'FlutterForge',

  // Common actions
  'ok': 'Tamam',
  'cancel': 'İptal',
  'save': 'Kaydet',
  'delete': 'Sil',
  'edit': 'Düzenle',
  'close': 'Kapat',
  'done': 'Bitti',
  'retry': 'Tekrar Dene',
  'search': 'Ara',
  'continue': 'Devam',
  'back': 'Geri',
  'next': 'İleri',
  'skip': 'Atla',
  'submit': 'Gönder',
  'confirm': 'Onayla',
  'yes': 'Evet',
  'no': 'Hayır',

  // Status
  'loading': 'Yükleniyor...',
  'error': 'Hata',
  'success': 'Başarılı',
  'warning': 'Uyarı',
  'info': 'Bilgi',

  // Empty states
  'empty': 'Veri bulunamadı',
  'no_results': 'Sonuç bulunamadı',
  'no_items': 'Öğe yok',

  // Navigation
  'home': 'Ana Sayfa',
  'settings': 'Ayarlar',
  'profile': 'Profil',
  'notifications': 'Bildirimler',
  'help': 'Yardım',
  'about': 'Hakkında',

  // Auth
  'login': 'Giriş Yap',
  'logout': 'Çıkış Yap',
  'register': 'Kayıt Ol',
  'sign_up': 'Üye Ol',
  'forgot_password': 'Şifremi Unuttum',
  'reset_password': 'Şifre Sıfırla',
  'email': 'E-posta',
  'password': 'Şifre',
  'confirm_password': 'Şifre Tekrar',
  'username': 'Kullanıcı Adı',

  // Validation
  'required_field': 'Bu alan zorunludur',
  'invalid_email': 'Geçerli bir e-posta girin',
  'password_too_short': 'Şifre en az 8 karakter olmalıdır',
  'passwords_dont_match': 'Şifreler eşleşmiyor',

  // Errors
  'generic_error': 'Bir hata oluştu',
  'network_error': 'Ağ hatası. Bağlantınızı kontrol edin.',
  'server_error': 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.',
  'unauthorized': 'Bu işlem için yetkiniz yok',
  'not_found': 'Bulunamadı',
  'timeout': 'İstek zaman aşımına uğradı',
};

/// German translations.
const Map<String, String> _deTranslations = {
  'app_name': 'FlutterForge',
  'ok': 'OK',
  'cancel': 'Abbrechen',
  'save': 'Speichern',
  'delete': 'Löschen',
  'edit': 'Bearbeiten',
  'close': 'Schließen',
  'done': 'Fertig',
  'retry': 'Wiederholen',
  'search': 'Suchen',
  'loading': 'Laden...',
  'error': 'Fehler',
  'success': 'Erfolg',
  'empty': 'Keine Daten verfügbar',
  'no_results': 'Keine Ergebnisse',
  'home': 'Startseite',
  'settings': 'Einstellungen',
  'profile': 'Profil',
  'login': 'Anmelden',
  'logout': 'Abmelden',
  'email': 'E-Mail',
  'password': 'Passwort',
};

/// French translations.
const Map<String, String> _frTranslations = {
  'app_name': 'FlutterForge',
  'ok': 'OK',
  'cancel': 'Annuler',
  'save': 'Enregistrer',
  'delete': 'Supprimer',
  'edit': 'Modifier',
  'close': 'Fermer',
  'done': 'Terminé',
  'retry': 'Réessayer',
  'search': 'Rechercher',
  'loading': 'Chargement...',
  'error': 'Erreur',
  'success': 'Succès',
  'empty': 'Aucune donnée disponible',
  'no_results': 'Aucun résultat',
  'home': 'Accueil',
  'settings': 'Paramètres',
  'profile': 'Profil',
  'login': 'Connexion',
  'logout': 'Déconnexion',
  'email': 'E-mail',
  'password': 'Mot de passe',
};

/// Spanish translations.
const Map<String, String> _esTranslations = {
  'app_name': 'FlutterForge',
  'ok': 'Aceptar',
  'cancel': 'Cancelar',
  'save': 'Guardar',
  'delete': 'Eliminar',
  'edit': 'Editar',
  'close': 'Cerrar',
  'done': 'Hecho',
  'retry': 'Reintentar',
  'search': 'Buscar',
  'loading': 'Cargando...',
  'error': 'Error',
  'success': 'Éxito',
  'empty': 'No hay datos disponibles',
  'no_results': 'Sin resultados',
  'home': 'Inicio',
  'settings': 'Configuración',
  'profile': 'Perfil',
  'login': 'Iniciar sesión',
  'logout': 'Cerrar sesión',
  'email': 'Correo electrónico',
  'password': 'Contraseña',
};
