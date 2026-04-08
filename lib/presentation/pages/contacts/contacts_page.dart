import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkme/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../providers/contact_provider.dart';
import '../../../domain/entities/contact.dart';
import 'widgets/contact_list_tile.dart';
import 'widgets/contact_form_dialog.dart';

class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});

  Future<void> _showContactForm(BuildContext context, WidgetRef ref, {Contact? contact}) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => ContactFormDialog(contact: contact),
    );
    if (result == null) return;
    if (contact == null) {
      await ref.read(contactsNotifierProvider.notifier).addContact(result);
    } else {
      await ref.read(contactsNotifierProvider.notifier).updateContact(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsState = ref.watch(contactsNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contactsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: contactsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(l10n.genericError(err.toString()))),
        data: (contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noContactsYet),
                  Text(l10n.tapToAddContact),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (ctx, i) => ContactListTile(
              contact: contacts[i],
              onEdit: () => _showContactForm(context, ref, contact: contacts[i]),
              onDelete: () => ref
                  .read(contactsNotifierProvider.notifier)
                  .deleteContact(contacts[i].id),
            ),
          );
        },
      ),
    );
  }
}
