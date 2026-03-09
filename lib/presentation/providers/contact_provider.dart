import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/contact.dart';
import '../../domain/usecases/get_contacts.dart';
import '../../domain/usecases/add_contact.dart';
import '../../domain/usecases/update_contact.dart';
import '../../domain/usecases/delete_contact.dart';
import '../../injection_container.dart';
import 'auth_provider.dart';

class ContactsNotifier extends AsyncNotifier<List<Contact>> {
  @override
  Future<List<Contact>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return [];
    final useCase = sl<GetContacts>();
    final result = await useCase(userId);
    return result.fold((_) => [], (contacts) => contacts);
  }

  Future<void> addContact(Contact contact) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final useCase = sl<AddContact>();
    final result = await useCase(userId, contact);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (newContact) {
        final current = state.valueOrNull ?? [];
        state = AsyncData([...current, newContact]);
      },
    );
  }

  Future<void> updateContact(Contact contact) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final useCase = sl<UpdateContact>();
    final result = await useCase(userId, contact);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (updated) {
        final current = state.valueOrNull ?? [];
        state = AsyncData(
          current.map((c) => c.id == updated.id ? updated : c).toList(),
        );
      },
    );
  }

  Future<void> deleteContact(String contactId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final useCase = sl<DeleteContact>();
    final result = await useCase(userId, contactId);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) {
        final current = state.valueOrNull ?? [];
        state = AsyncData(current.where((c) => c.id != contactId).toList());
      },
    );
  }
}

final contactsNotifierProvider =
    AsyncNotifierProvider<ContactsNotifier, List<Contact>>(ContactsNotifier.new);
