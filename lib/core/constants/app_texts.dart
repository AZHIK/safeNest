import '../localization/app_localization.dart';

class AppTexts {
  AppTexts._();

  static String t(String key, AppLanguage lang) {
    // print('AppTexts: Translating $key for $lang');
    return AppTranslations.get(key, lang);
  }

  // General
  static String appName(AppLanguage l) => t('appName', l);
  static String tagline(AppLanguage l) => t('tagline', l);

  // Auth
  static String loginTitle(AppLanguage l) => t('loginTitle', l);
  static String registerTitle(AppLanguage l) => t('registerTitle', l);
  static String continueAnonymously(AppLanguage l) =>
      t('continueAnonymously', l);
  static String enterPhone(AppLanguage l) => t('enterPhone', l);
  static String weWillSendCode(AppLanguage l) => t('weWillSendCode', l);
  static String continueButton(AppLanguage l) => t('continueButton', l);
  static String verifyNumber(AppLanguage l) => t('verifyNumber', l);
  static String enterOTP(AppLanguage l) => t('enterOTP', l);
  static String verifyButton(AppLanguage l) => t('verifyButton', l);
  static String resendCode(AppLanguage l) => t('resendCode', l);
  static String profileSetupTitle(AppLanguage l) => t('profileSetupTitle', l);
  static String nameLabel(AppLanguage l) => t('nameLabel', l);
  static String skipButton(AppLanguage l) => t('skipButton', l);
  static String finishButton(AppLanguage l) => t('finishButton', l);

  // SOS
  static String sosTitle(AppLanguage l) => t('sosTitle', l);
  static String sosButton(AppLanguage l) => t('sosButton', l);
  static String sosActive(AppLanguage l) => t('sosActive', l);
  static String sosInstruction(AppLanguage l) => t('sosInstruction', l);

  // Reporting
  static String reportTitle(AppLanguage l) => t('reportTitle', l);
  static String addEvidence(AppLanguage l) => t('addEvidence', l);
  static String submitReport(AppLanguage l) => t('submitReport', l);

  // Training
  static String trainingTitle(AppLanguage l) => t('trainingTitle', l);
  static String selfDefense(AppLanguage l) => t('selfDefense', l);
  static String awareness(AppLanguage l) => t('awareness', l);
  static String legalInfo(AppLanguage l) => t('legalInfo', l);

  // Errors
  static String networkError(AppLanguage l) => t('networkError', l);
  static String unknownError(AppLanguage l) => t('unknownError', l);
}
