import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth_controller.dart';
import '../../domain/auth_models.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/localization/app_localization.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final List<TrustedContact> _contacts = [];

  @override
  void dispose() {
    _nameController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _addContact() {
    if (_contactNameController.text.isNotEmpty &&
        _contactPhoneController.text.isNotEmpty) {
      setState(() {
        _contacts.add(
          TrustedContact(
            name: _contactNameController.text,
            phoneNumber: _contactPhoneController.text,
          ),
        );
        _contactNameController.clear();
        _contactPhoneController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.profileSetupTitle(lang)),
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(AppTexts.skipButton(lang)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  AppTranslations.get('tellUsName', lang),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppTexts.nameLabel(lang),
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  AppTranslations.get('trustedContacts', lang),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  AppTranslations.get('emergencyNotify', lang),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ..._contacts.map(
                  (contact) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        child: Text(
                          contact.name[0].toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(contact.phoneNumber),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            _contacts.remove(contact);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _contactNameController,
                        decoration: InputDecoration(
                          hintText: AppTranslations.get(
                            'contactNameHint',
                            lang,
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.person_add_outlined),
                        ),
                      ),
                      const Divider(),
                      TextField(
                        controller: _contactPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: AppTranslations.get(
                            'phoneNumberHint',
                            lang,
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _addContact,
                        icon: const Icon(Icons.add),
                        label: Text(
                          AppTranslations.get('addContactButton', lang),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty) {
                      await ref
                          .read(authControllerProvider.notifier)
                          .completeProfile(_nameController.text, _contacts);
                    }
                    if (context.mounted) {
                      context.go('/permissions');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppTexts.finishButton(lang)),
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
