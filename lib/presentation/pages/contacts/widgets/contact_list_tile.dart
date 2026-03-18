import 'package:flutter/material.dart';
import 'package:checkme/l10n/app_localizations.dart';
import '../../../../domain/entities/contact.dart';

class ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
        ),
      ),
      title: Text(contact.name),
      subtitle: Text(contact.phone != null
          ? '${contact.email} · ${contact.phone}'
          : contact.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.deleteContact),
                  content: Text(l10n.deleteContactConfirm(contact.name)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l10n.delete,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) onDelete();
            },
          ),
        ],
      ),
    );
  }
}
