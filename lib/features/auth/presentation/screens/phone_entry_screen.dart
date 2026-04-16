import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth_controller.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/localization/app_localization.dart';
import '../../../../core/localization/language_toggle.dart';
import '../../domain/auth_models.dart';

class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  String _fullPhoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final lang = ref.watch(localeProvider);

    // Listen for state changes to navigate
    ref.listen(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.otpSent) {
        context.push('/otp');
      } else if (next.status == AuthStatus.anonymous) {
        context.go('/home');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Align(alignment: Alignment.topRight, child: LanguageToggle()),
                const SizedBox(height: 20),
                Text(
                  AppTexts.appName(lang),
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppTexts.tagline(lang),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Text(
                  AppTexts.enterPhone(lang),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  AppTexts.weWillSendCode(lang),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                IntlPhoneField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: AppTexts.enterPhone(lang),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  initialCountryCode: 'TZ',
                  onChanged: (phone) {
                    setState(() {
                      _fullPhoneNumber = phone.completeNumber;
                    });
                  },
                  onSubmitted: (value) {
                    if (_fullPhoneNumber.isNotEmpty) {
                      authController.requestOTP(_fullPhoneNumber);
                    }
                  },
                ),
                const SizedBox(height: 32),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : () {
                          // Bypassing requestOTP for UI building stage as requested
                          /*
                          if (_fullPhoneNumber.isNotEmpty) {
                            authController.requestOTP(_fullPhoneNumber);
                          } else if (_phoneController.text.isNotEmpty) {
                            authController.requestOTP(_phoneController.text);
                          }
                          */

                          if (_fullPhoneNumber.isNotEmpty ||
                              _phoneController.text.isNotEmpty) {
                            context.push('/otp');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: authState.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(AppTexts.continueButton(lang)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => authController.continueAnonymously(),
                  child: Text(AppTexts.continueAnonymously(lang)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
