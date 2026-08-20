import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleController extends ChangeNotifier {
  static const _storageKey = 'app_language';
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final language = preferences.getString(_storageKey);
    if (language == 'fr' || language == 'en') {
      _locale = Locale(language!);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'fr' && languageCode != 'en') return;
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, languageCode);
  }

  String text(String key) => AppTranslations.values[languageCode]?[key] ?? key;
}

class AppLocaleScope extends InheritedNotifier<AppLocaleController> {
  const AppLocaleScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppLocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope is missing above this context.');
    return scope!.notifier!;
  }
}

class AppTranslations {
  static const values = <String, Map<String, String>>{
    'fr': {
      'appName': 'Smart Laboratory',
      'home': 'Accueil',
      'products': 'Produits',
      'alerts': 'Alertes',
      'more': 'Plus',
      'logout': 'Déconnexion',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'settingsSubtitle': 'Préférences de l’application',
      'help': 'Aide & Support',
      'helpSubtitle': 'Besoin d’aide ?',
      'about': 'À propos',
      'language': 'Langue',
      'languageSubtitle': 'Choisir la langue de l’application',
      'french': 'Français',
      'english': 'Anglais',
      'languageChanged': 'Langue mise à jour',
      'manageProfile': 'Gérer vos informations',
      'version': 'Version 1.0.0',
    },
    'en': {
      'appName': 'Smart Laboratory',
      'home': 'Home',
      'products': 'Products',
      'alerts': 'Alerts',
      'more': 'More',
      'logout': 'Logout',
      'profile': 'Profile',
      'settings': 'Settings',
      'settingsSubtitle': 'Application preferences',
      'help': 'Help & Support',
      'helpSubtitle': 'Need help?',
      'about': 'About',
      'language': 'Language',
      'languageSubtitle': 'Choose the application language',
      'french': 'French',
      'english': 'English',
      'languageChanged': 'Language updated',
      'manageProfile': 'Manage your information',
      'version': 'Version 1.0.0',
    },
  };
}
