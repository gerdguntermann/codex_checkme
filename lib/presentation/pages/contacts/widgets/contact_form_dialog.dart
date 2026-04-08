import 'package:flutter/material.dart';
import 'package:checkme/l10n/app_localizations.dart';
import '../../../../domain/entities/contact.dart';

class ContactFormDialog extends StatefulWidget {
  final Contact? contact;

  const ContactFormDialog({super.key, this.contact});

  @override
  State<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<ContactFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.contact == null ? l10n.addContact : l10n.editContact),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.fieldName,
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.fieldEmail,
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.emailRequired;
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(v.trim())) return l10n.invalidEmail;
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.fieldPhone,
                prefixIcon: const Icon(Icons.phone),
                hintText: l10n.phoneHint,
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              final phone = _phoneController.text.trim();
              Navigator.pop(
                context,
                Contact(
                  id: widget.contact?.id ?? '',
                  name: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  phone: phone.isEmpty ? null : phone,
                ),
              );
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
