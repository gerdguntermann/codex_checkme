import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/config/config_page.dart';
import '../../presentation/pages/contacts/contacts_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/config',
        name: 'config',
        builder: (context, state) => const ConfigPage(),
      ),
      GoRoute(
        path: '/contacts',
        name: 'contacts',
        builder: (context, state) => const ContactsPage(),
      ),
    ],
  );
});
