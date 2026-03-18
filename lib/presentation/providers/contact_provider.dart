import 'package:checkme/core/utils/app_logger.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/contact.dart';
import 'auth_provider.dart';
import 'service_providers.dart';

class ContactsNotifier extends AsyncNotifier<List<Contact>> {
  @override
  Future<List<Contact>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return [];
    log('build – loading contacts', name: 'ContactsNotifier');
    return ref.read(contactServiceProvider).getContacts(userId);
  }

  Future<void> addContact(Contact contact) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    try {
      final created = await ref.read(contactServiceProvider).addContact(userId, contact);
      state = AsyncData([...state.valueOrNull ?? [], created]);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> updateContact(Contact contact) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    try {
      final updated = await ref.read(contactServiceProvider).updateContact(userId, contact);
      final current = state.valueOrNull ?? [];
      state = AsyncData(current.map((c) => c.id == updated.id ? updated : c).toList());
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> deleteContact(String contactId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    try {
      await ref.read(contactServiceProvider).deleteContact(userId, contactId);
      state = AsyncData((state.valueOrNull ?? []).where((c) => c.id != contactId).toList());
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

final contactsNotifierProvider =
    AsyncNotifierProvider<ContactsNotifier, List<Contact>>(ContactsNotifier.new);
