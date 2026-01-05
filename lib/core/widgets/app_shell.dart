import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../../features/accounting/presentation/pages/accounting_page.dart';
import '../../features/devices/presentation/pages/devices_page.dart';
import '../../features/menu/presentation/pages/menu_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/sessions/presentation/pages/sessions_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/users/presentation/pages/dashboard_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _destinations = <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.grid_view_rounded),
      label: Text(AppStrings.navDashboard),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.devices_other_rounded),
      label: Text(AppStrings.navDevices),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.timer_rounded),
      label: Text(AppStrings.navSessions),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.restaurant_menu_rounded),
      label: Text(AppStrings.navMenu),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.shopping_cart_rounded),
      label: Text(AppStrings.navOrders),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.bar_chart_rounded),
      label: Text(AppStrings.navAccounting),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_rounded),
      label: Text(AppStrings.navSettings),
    ),
  ];

  static const _pages = <Widget>[
    DashboardPage(),
    DevicesPage(),
    SessionsPage(),
    MenuPage(),
    OrdersPage(),
    AccountingPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            extended: true,
            backgroundColor: theme.colorScheme.surface,
            destinations: _destinations,
            minExtendedWidth: 240,
            labelType: NavigationRailLabelType.none,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _pages[_index],
          ),
        ],
      ),
    );
  }
}
