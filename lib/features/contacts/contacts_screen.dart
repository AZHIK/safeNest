import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';
import '../../core/models/trusted_contact_model.dart';
import '../../core/repositories/auth_repository.dart';

class TrustedContactsScreen extends ConsumerStatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  ConsumerState<TrustedContactsScreen> createState() =>
      _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends ConsumerState<TrustedContactsScreen> {
  late Future<List<TrustedContact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = _fetchContacts();
  }

  Future<List<TrustedContact>> _fetchContacts() async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.getTrustedContacts();
  }

  Future<void> _deleteContact(String contactId) async {
    final lang = ref.read(localeProvider);
    final repo = ref.read(authRepositoryProvider);

    try {
      await repo.removeTrustedContact(contactId);
      setState(() {
        _contactsFuture = _fetchContacts();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == AppLanguage.english
                  ? 'Contact removed'
                  : 'Mwasiliani ameondolewa',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == AppLanguage.english
                  ? 'Failed to remove contact'
                  : 'Imeshindwa kuondoa mwasiliani',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAddContactDialog() {
    final lang = ref.read(localeProvider);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          lang == AppLanguage.english
              ? 'Add Trusted Contact'
              : 'Ongeza Mwasiliani',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: lang == AppLanguage.english ? 'Name' : 'Jina',
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: lang == AppLanguage.english
                    ? 'Phone Number'
                    : 'Namba ya Simu',
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: relationshipController,
              decoration: InputDecoration(
                labelText: lang == AppLanguage.english
                    ? 'Relationship (optional)'
                    : 'Uhusiano (sio lazima)',
                prefixIcon: const Icon(Icons.people),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang == AppLanguage.english ? 'Cancel' : 'Ghairi'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                return;
              }

              final repo = ref.read(authRepositoryProvider);
              try {
                await repo.addTrustedContact(
                  TrustedContactCreate(
                    name: nameController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                    relationship: relationshipController.text.trim().isEmpty
                        ? null
                        : relationshipController.text.trim(),
                  ),
                );
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {
                    _contactsFuture = _fetchContacts();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        lang == AppLanguage.english
                            ? 'Contact added'
                            : 'Mwasiliani ameongezwa',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        lang == AppLanguage.english
                            ? 'Failed to add contact'
                            : 'Imeshindwa kuongeza mwasiliani',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(lang == AppLanguage.english ? 'Add' : 'Ongeza'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang == AppLanguage.english
              ? 'Trusted Contacts'
              : 'Wasiliani Waamini',
        ),
      ),
      body: FutureBuilder<List<TrustedContact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Text(
                      lang == AppLanguage.english
                          ? 'Failed to load contacts'
                          : 'Imeshindwa kupakia wasiliani',
                      style: const TextStyle(
                        fontSize: AppSizes.fontSubtitle,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.p24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _contactsFuture = _fetchContacts();
                        });
                      },
                      child: Text(
                        lang == AppLanguage.english ? 'Retry' : 'Jaribu tena',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final contacts = snapshot.data ?? [];

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.p24),
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: Text(
                        lang == AppLanguage.english
                            ? 'These contacts will be notified immediately when you trigger an SOS.'
                            : 'Wasiliani hawa wataarifiwa mara moja unapobonyeza SOS.',
                        style: const TextStyle(fontSize: AppSizes.fontSmall),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: contacts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.p24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: AppSizes.p16),
                              Text(
                                lang == AppLanguage.english
                                    ? 'No trusted contacts'
                                    : 'Hakuna wasiliani waamini',
                                style: const TextStyle(
                                  fontSize: AppSizes.fontSubtitle,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSizes.p8),
                              Text(
                                lang == AppLanguage.english
                                    ? 'Add trusted contacts who will be notified during emergencies.'
                                    : 'Ongeza wasiliani waamini watakaoarifiwa wakati wa dharura.',
                                style: TextStyle(
                                  fontSize: AppSizes.fontSmall,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSizes.p12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radius12,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(
                                AppSizes.p12,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.secondary.withValues(
                                  alpha: 0.1,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.secondary,
                                ),
                              ),
                              title: Text(
                                contact.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(contact.phoneNumber),
                                  if (contact.relationship != null)
                                    Text(
                                      contact.relationship!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  if (contact.isVerified)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Verified',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                                onPressed: () => _deleteContact(contact.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContactDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          lang == AppLanguage.english ? 'Add Contact' : 'Ongeza Mwasiliani',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
