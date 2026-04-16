import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { english, swahili }

final localeProvider = NotifierProvider<LocaleController, AppLanguage>(() {
  return LocaleController();
});

class LocaleController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    return AppLanguage.english;
  }

  void toggleLanguage() {
    state = state == AppLanguage.english
        ? AppLanguage.swahili
        : AppLanguage.english;
  }

  void setLanguage(AppLanguage language) {
    print('LocaleController: Setting language to $language');
    state = language;
    print('LocaleController: State is now $state');
  }
}

class AppTranslations {
  static const Map<String, Map<AppLanguage, String>> _translations = {
    'appName': {
      AppLanguage.english: "SafeNest",
      AppLanguage.swahili: "SafeNest",
    },
    'tagline': {
      AppLanguage.english: "Stay Safe. Stay Connected.",
      AppLanguage.swahili: "Baki Salama. Baki na Mawasiliano.",
    },
    'loginTitle': {
      AppLanguage.english: "Welcome Back",
      AppLanguage.swahili: "Karibu Tena",
    },
    'registerTitle': {
      AppLanguage.english: "Create an Account",
      AppLanguage.swahili: "Tengeneza Akaunti",
    },
    'continueAnonymously': {
      AppLanguage.english: "Continue Anonymously",
      AppLanguage.swahili: "Endelea Bila Jina",
    },
    'enterPhone': {
      AppLanguage.english: "Enter your number",
      AppLanguage.swahili: "Ingiza namba yako",
    },
    'weWillSendCode': {
      AppLanguage.english: "We’ll send you a code",
      AppLanguage.swahili: "Tutakutumia namba ya siri",
    },
    'continueButton': {
      AppLanguage.english: "Continue",
      AppLanguage.swahili: "Endelea",
    },
    'verifyNumber': {
      AppLanguage.english: "Verify your number",
      AppLanguage.swahili: "Hakiki namba yako",
    },
    'enterOTP': {
      AppLanguage.english: "Enter the 6-digit code sent to",
      AppLanguage.swahili: "Ingiza namba ya siri uliyotumiwa",
    },
    'verifyButton': {
      AppLanguage.english: "Verify",
      AppLanguage.swahili: "Hakiki",
    },
    'resendCode': {
      AppLanguage.english: "Resend Code",
      AppLanguage.swahili: "Tuma Tena",
    },
    'profileSetupTitle': {
      AppLanguage.english: "Complete Profile",
      AppLanguage.swahili: "Kamilisha Profaili",
    },
    'nameLabel': {
      AppLanguage.english: "Name (Optional)",
      AppLanguage.swahili: "Jina (Si Lazima)",
    },
    'skipButton': {AppLanguage.english: "Skip", AppLanguage.swahili: "Ruka"},
    'finishButton': {
      AppLanguage.english: "Finish",
      AppLanguage.swahili: "Maliza",
    },
    'sosTitle': {
      AppLanguage.english: "Quick Help",
      AppLanguage.swahili: "Msaada wa Haraka",
    },
    'sosButton': {
      AppLanguage.english: "Send Alert",
      AppLanguage.swahili: "Tuma Tahadhari",
    },
    'sosActive': {
      AppLanguage.english: "Alert Sent",
      AppLanguage.swahili: "Tahadhari Imetumwa",
    },
    'sosInstruction': {
      AppLanguage.english: "Help is on the way. Stay calm.",
      AppLanguage.swahili: "Msaada unakuja. Tulia.",
    },
    'reportTitle': {
      AppLanguage.english: "Secure Report",
      AppLanguage.swahili: "Ripoti kwa Usalama",
    },
    'addEvidence': {
      AppLanguage.english: "Add Document or Photo",
      AppLanguage.swahili: "Ongeza Nyaraka au Picha",
    },
    'submitReport': {
      AppLanguage.english: "Submit Securely",
      AppLanguage.swahili: "Tuma kwa Usalama",
    },
    'trainingTitle': {
      AppLanguage.english: "Resources center",
      AppLanguage.swahili: "Kituo cha Rasilimali",
    },
    'selfDefense': {
      AppLanguage.english: "Self-Defense Basics",
      AppLanguage.swahili: "Misingi ya Kujilinda",
    },
    'awareness': {
      AppLanguage.english: "Situational Awareness",
      AppLanguage.swahili: "Ufahamu wa Mazingira",
    },
    'legalInfo': {
      AppLanguage.english: "Know Your Rights",
      AppLanguage.swahili: "Jua Haki Zako",
    },
    'networkError': {
      AppLanguage.english: "Please check your connection.",
      AppLanguage.swahili: "Tafadhali kagua mtandao wako.",
    },
    'unknownError': {
      AppLanguage.english: "Something went wrong. Please try again.",
      AppLanguage.swahili: "Kuna kitu kimeenda vibaya. Jaribu tena.",
    },
    'homeNav': {AppLanguage.english: "Home", AppLanguage.swahili: "Nyumbani"},
    'mapNav': {AppLanguage.english: "Map", AppLanguage.swahili: "Ramani"},
    'reportNav': {AppLanguage.english: "Report", AppLanguage.swahili: "Ripoti"},
    'messageNav': {
      AppLanguage.english: "Messages",
      AppLanguage.swahili: "Ujumbe",
    },
    'trainingNav': {
      AppLanguage.english: "Training",
      AppLanguage.swahili: "Mafunzo",
    },
    // Profile Setup
    'tellUsName': {
      AppLanguage.english: "Tell us your name",
      AppLanguage.swahili: "Tuambie jina lako",
    },
    'trustedContacts': {
      AppLanguage.english: "Trusted Contacts",
      AppLanguage.swahili: "Watu wa Karibu",
    },
    'emergencyNotify': {
      AppLanguage.english:
          "In case of emergency, these people will be notified.",
      AppLanguage.swahili: "Ikifika dharura, watu hawa watafahamishwa.",
    },
    'contactNameHint': {
      AppLanguage.english: "Contact Name",
      AppLanguage.swahili: "Jina la Mtu",
    },
    'phoneNumberHint': {
      AppLanguage.english: "Phone Number",
      AppLanguage.swahili: "Namba ya Simu",
    },
    'addContactButton': {
      AppLanguage.english: "Add Contact",
      AppLanguage.swahili: "Ongeza Mtu",
    },
    // Settings
    'settingsTitle': {
      AppLanguage.english: "Settings",
      AppLanguage.swahili: "Mipangilio",
    },
    'preferencesHeader': {
      AppLanguage.english: "Preferences",
      AppLanguage.swahili: "Mapendeleo",
    },
    'languageLabel': {
      AppLanguage.english: "Language",
      AppLanguage.swahili: "Lugha",
    },
    'securityHeader': {
      AppLanguage.english: "Security",
      AppLanguage.swahili: "Usalama",
    },
    'appLockLabel': {
      AppLanguage.english: "App Lock",
      AppLanguage.swahili: "Kufunga Programu",
    },
    'appLockSub': {
      AppLanguage.english: "Require PIN or Biometrics",
      AppLanguage.swahili: "Inahitaji PIN au Alama za Kidole",
    },
    'discreetModeLabel': {
      AppLanguage.english: "Discreet Mode",
      AppLanguage.swahili: "Hali ya Siri",
    },
    'discreetModeSub': {
      AppLanguage.english: "Hide emergency terms in UI",
      AppLanguage.swahili: "Ficha maneno ya dharura kwenye UI",
    },
    'supportHeader': {
      AppLanguage.english: "Support",
      AppLanguage.swahili: "Msaada",
    },
    'helpCenterLabel': {
      AppLanguage.english: "Help Center",
      AppLanguage.swahili: "Kituo cha Msaada",
    },
    'privacyPolicyLabel': {
      AppLanguage.english: "Privacy Policy",
      AppLanguage.swahili: "Sera ya Faragha",
    },
    'logoutButton': {
      AppLanguage.english: "Log Out",
      AppLanguage.swahili: "Ondoka",
    },
    // Map
    'mapPlaceholder': {
      AppLanguage.english: "Maps Integration Placeholder",
      AppLanguage.swahili: "Eneo la Ramani",
    },
    'searchCentersHint': {
      AppLanguage.english: "Search for help centers...",
      AppLanguage.swahili: "Tafuta vituo vya msaada...",
    },
    'filterAll': {AppLanguage.english: "All", AppLanguage.swahili: "Zote"},
    'filterPolice': {
      AppLanguage.english: "Police",
      AppLanguage.swahili: "Polisi",
    },
    'filterHealth': {
      AppLanguage.english: "Health",
      AppLanguage.swahili: "Afya",
    },
    'filterLegal': {
      AppLanguage.english: "Legal",
      AppLanguage.swahili: "Sheria",
    },
    'filterSupport': {
      AppLanguage.english: "Support",
      AppLanguage.swahili: "Msaada",
    },
    'callButton': {
      AppLanguage.english: "Call",
      AppLanguage.swahili: "Piga Simu",
    },
    'directionsButton': {
      AppLanguage.english: "Directions",
      AppLanguage.swahili: "Maelekezo",
    },
    // Messaging
    'messagesTitle': {
      AppLanguage.english: "Messages",
      AppLanguage.swahili: "Ujumbe",
    },
    'officialSupport': {
      AppLanguage.english: "Official Support",
      AppLanguage.swahili: "Msaada Rasmi",
    },
    'typeMessageHint': {
      AppLanguage.english: "Type a message...",
      AppLanguage.swahili: "Andika ujumbe...",
    },
    // Training
    'emergencyActions': {
      AppLanguage.english: "Emergency Actions",
      AppLanguage.swahili: "Hatua za Dharura",
    },
    'crisesDesc': {
      AppLanguage.english: "What to do during crises.",
      AppLanguage.swahili: "Nini cha kufanya wakati wa majanga.",
    },
    'lessonsTitle': {
      AppLanguage.english: "Self-Defense Lessons",
      AppLanguage.swahili: "Masomo ya Kujilinda",
    },
    'lessonStrikes': {
      AppLanguage.english: "Basic Strikes",
      AppLanguage.swahili: "Mashambulizi ya Msingi",
    },
    'lessonHolds': {
      AppLanguage.english: "Escaping Holds",
      AppLanguage.swahili: "Kutoroka Kukamatwa",
    },
    'lessonEnv': {
      AppLanguage.english: "Using Your Environment",
      AppLanguage.swahili: "Kutumia Mazingira Yako",
    },
    'lessonDeescalation': {
      AppLanguage.english: "De-escalation Tactics",
      AppLanguage.swahili: "Mbinu za Kupunguza Ukali",
    },
    'beginner': {
      AppLanguage.english: "Beginner",
      AppLanguage.swahili: "Anayeanza",
    },
    'intermediate': {
      AppLanguage.english: "Intermediate",
      AppLanguage.swahili: "Kati",
    },
    // SOS
    'sendingAlert': {
      AppLanguage.english: "Sending Alert...",
      AppLanguage.swahili: "Inatuma Tahadhari...",
    },
    'sosSubtitleIdle': {
      AppLanguage.english:
          "Tap the button below to alert emergency services and your trusted contacts immediately.",
      AppLanguage.swahili:
          "Gonga kitufe hapo chini ili kuwajulisha huduma za dharura na watu wako wa karibu mara moja.",
    },
    'sosSubtitleSending': {
      AppLanguage.english:
          "Connecting to emergency network and broadcasting your live location...",
      AppLanguage.swahili:
          "Inatafuta mtandao wa dharura na kutoa eneo lako moja kwa moja...",
    },
    'liveTracking': {
      AppLanguage.english: "Live GPS Tracking Enabled",
      AppLanguage.swahili: "Ufuatiliaji wa GPS Umewezeshwa",
    },
  };

  static String get(String key, AppLanguage lang) {
    final translation = _translations[key]?[lang] ?? key;
    // debugPrint('AppTranslations: Getting $key for $lang -> $translation');
    return translation;
  }
}
