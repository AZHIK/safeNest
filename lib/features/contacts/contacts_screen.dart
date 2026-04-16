import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class TrustedContactsScreen extends StatelessWidget {
  const TrustedContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> contacts = [
      {'name': 'Jane Doe', 'phone': '+254 712 345 678', 'relation': 'Sister'},
      {'name': 'John Smith', 'phone': '+254 723 456 789', 'relation': 'Friend'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Trusted Contacts')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.p24),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: AppSizes.p16),
                const Expanded(
                  child: Text(
                    'These contacts will be notified immediately when you trigger an SOS.',
                    style: TextStyle(fontSize: AppSizes.fontSmall),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.p12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(AppSizes.p12),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.secondary,
                      ),
                    ),
                    title: Text(
                      contact['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact['phone']!),
                        Text(
                          contact['relation']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Contact', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
