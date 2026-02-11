import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/presentation/widgets/drawer_widget.dart';
import 'package:islamic_library_flutter/presentation/widgets/mini_player_widget.dart';
import 'package:islamic_library_flutter/presentation/widgets/connectivity_banner.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';

import 'package:islamic_library_flutter/core/utils/scaffold_utils.dart';
import 'package:islamic_library_flutter/core/services/update_service.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔔 MainScaffold: initState');

    // Check for updates on app startup
    Future.microtask(() {
      if (mounted) {
        UpdateService.checkForUpdate(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔔 MainScaffold: build');
    final location = GoRouterState.of(context).uri.toString();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: GlobalScaffoldService.scaffoldKey,
      drawer: const DrawerWidget(),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerWidget(),
          BottomNavigationBar(
            currentIndex: _getSelectedIndex(location),
            onTap: (index) => _onItemTapped(index, context),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_filled),
                activeIcon: const Icon(
                  Icons.home_filled,
                  color: AppTheme.primaryColor,
                ),
                label: l10n.home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.import_contacts_outlined),
                activeIcon: const Icon(
                  Icons.import_contacts_rounded,
                  color: AppTheme.primaryColor,
                ),
                label: l10n.quranMushaf,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_outline_rounded),
                activeIcon: const Icon(
                  Icons.people_rounded,
                  color: AppTheme.primaryColor,
                ),
                label: l10n.reciters,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu_book_outlined),
                activeIcon: const Icon(
                  Icons.menu_book_rounded,
                  color: AppTheme.primaryColor,
                ),
                label: l10n.hadith,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.account_circle_outlined),
                activeIcon: const Icon(
                  Icons.account_circle,
                  color: AppTheme.primaryColor,
                ),
                label: l10n.myAccount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location == '/quran-text') return 1;
    if (location == '/all-reciters') return 2;
    if (location == '/hadith') return 3;
    if (location == '/profile') return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.push('/quran-text');
        break;
      case 2:
        context.push('/all-reciters');
        break;
      case 3:
        context.push('/hadith');
        break;
      case 4:
        // context.push('/profile');
        break;
    }
  }
}
