import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/domain/entities/contact.dart';

void main() {
  const base = Contact(
    id: '1',
    name: 'Anna Müller',
    email: 'anna@example.com',
    phone: '+49123456789',
  );

  group('Contact.copyWith', () {
    test('overrides only specified fields', () {
      final copy = base.copyWith(name: 'Anna Schmidt', email: 'schmidt@example.com');
      expect(copy.name, 'Anna Schmidt');
      expect(copy.email, 'schmidt@example.com');
      expect(copy.id, base.id);
      expect(copy.phone, base.phone);
    });

    test('without arguments returns equal object', () {
      expect(base.copyWith(), base);
    });

    // Note: copyWith uses ??, so passing null for phone keeps the old value.
    test('phone: null in copyWith keeps existing phone', () {
      final copy = base.copyWith(phone: null);
      expect(copy.phone, base.phone);
    });
  });

  group('Contact equality (Equatable)', () {
    test('identical fields are equal', () {
      const same = Contact(
        id: '1',
        name: 'Anna Müller',
        email: 'anna@example.com',
        phone: '+49123456789',
      );
      expect(base, same);
    });

    test('different id → not equal', () {
      expect(base, isNot(equals(base.copyWith(id: '2'))));
    });

    test('different email → not equal', () {
      expect(base, isNot(equals(base.copyWith(email: 'other@example.com'))));
    });
  });

  group('Contact without phone', () {
    const noPhone = Contact(id: 'x', name: 'Bob', email: 'bob@b.com');

    test('phone is null', () {
      expect(noPhone.phone, isNull);
    });

    test('equality without phone', () {
      const same = Contact(id: 'x', name: 'Bob', email: 'bob@b.com');
      expect(noPhone, same);
    });
  });
}
