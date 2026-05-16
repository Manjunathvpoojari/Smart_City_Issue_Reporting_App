import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { english, kannada, hindi }

extension AppLanguageExt on AppLanguage {
  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.kannada:
        return 'ಕನ್ನಡ';
      case AppLanguage.hindi:
        return 'हिंदी';
    }
  }

  String get flag {
    switch (this) {
      case AppLanguage.english:
        return '🇬🇧';
      case AppLanguage.kannada:
        return '🇮🇳';
      case AppLanguage.hindi:
        return '🇮🇳';
    }
  }

  String t(String key) => translate(key, this);
}

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english);
  void setLanguage(AppLanguage lang) => state = lang;
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>(
  (ref) => LanguageNotifier(),
);

String translate(String key, AppLanguage language) {
  return _translations[key]?[language] ?? key;
}

const Map<String, Map<AppLanguage, String>> _translations = {
  'profile': {
    AppLanguage.english: 'Profile',
    AppLanguage.kannada: 'ಪ್ರೊಫೈಲ್',
    AppLanguage.hindi: 'प्रोफ़ाइल',
  },
  'my_reports': {
    AppLanguage.english: 'My Reports',
    AppLanguage.kannada: 'ನನ್ನ ವರದಿಗಳು',
    AppLanguage.hindi: 'मेरी रिपोर्ट',
  },
  'reported': {
    AppLanguage.english: 'Reported',
    AppLanguage.kannada: 'ವರದಿ',
    AppLanguage.hindi: 'रिपोर्ट',
  },
  'resolved': {
    AppLanguage.english: 'Resolved',
    AppLanguage.kannada: 'ಪರಿಹಾರ',
    AppLanguage.hindi: 'हल',
  },
  'pending': {
    AppLanguage.english: 'Pending',
    AppLanguage.kannada: 'ಬಾಕಿ',
    AppLanguage.hindi: 'लंबित',
  },
  'sign_out': {
    AppLanguage.english: 'Sign Out',
    AppLanguage.kannada: 'ಸೈನ್ ಔಟ್',
    AppLanguage.hindi: 'साइन आउट',
  },
  'sign_out_confirm': {
    AppLanguage.english: 'Are you sure you want to sign out?',
    AppLanguage.kannada: 'ನೀವು ಖಂಡಿತ ಸೈನ್ ಔಟ್ ಮಾಡಲು ಬಯಸುವಿರಾ?',
    AppLanguage.hindi: 'क्या आप वाकई साइन आउट करना चाहते हैं?',
  },
  'language': {
    AppLanguage.english: 'Language',
    AppLanguage.kannada: 'ಭಾಷೆ',
    AppLanguage.hindi: 'भाषा',
  },
  'select_language': {
    AppLanguage.english: 'Select Language',
    AppLanguage.kannada: 'ಭಾಷೆ ಆಯ್ಕೆ ಮಾಡಿ',
    AppLanguage.hindi: 'भाषा चुनें',
  },
  'app_version': {
    AppLanguage.english: 'App Version',
    AppLanguage.kannada: 'ಆವೃತ್ತಿ',
    AppLanguage.hindi: 'संस्करण',
  },
  'admin_dashboard': {
    AppLanguage.english: 'Admin Dashboard',
    AppLanguage.kannada: 'ನಿರ್ವಾಹಕ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
    AppLanguage.hindi: 'एडमिन डैशबोर्ड',
  },
  'report_issue': {
    AppLanguage.english: 'Report Issue',
    AppLanguage.kannada: 'ಸಮಸ್ಯೆ ವರದಿ',
    AppLanguage.hindi: 'समस्या रिपोर्ट',
  },
  'notifications': {
    AppLanguage.english: 'Notifications',
    AppLanguage.kannada: 'ಅಧಿಸೂಚನೆಗಳು',
    AppLanguage.hindi: 'सूचनाएं',
  },
};
