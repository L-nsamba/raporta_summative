import 'package:flutter/material.dart';

import '../enums/user_role.dart';
import '../theme/app_colors.dart';

enum AppDrawerDestination {
  dashboard,
  exploreReports,
  createReport,
  myReports,
  reportQueue,
  manageReports,
  notifications,
  profile,
}

class AppDrawer extends StatelessWidget {
  final UserRole role;
  final String userName;
  final String? userEmail;
  final AppDrawerDestination? selectedDestination;

  final ValueChanged<AppDrawerDestination> onDestinationSelected;
  final VoidCallback onSignOut;

  /// Optionally hide destinations that are not implemented yet.
  final Set<AppDrawerDestination>? enabledDestinations;

  const AppDrawer({
    super.key,
    required this.role,
    required this.userName,
    this.userEmail,
    this.selectedDestination,
    required this.onDestinationSelected,
    required this.onSignOut,
    this.enabledDestinations,
  });

List<AppDrawerDestination> get _destinations {
  if (role == UserRole.official) {
    return const [
      AppDrawerDestination.dashboard,
      AppDrawerDestination.reportQueue,
      AppDrawerDestination.manageReports,
      AppDrawerDestination.notifications,
      AppDrawerDestination.profile,
    ];
  }

  return const [
    AppDrawerDestination.dashboard,
    AppDrawerDestination.exploreReports,
    AppDrawerDestination.createReport,
    AppDrawerDestination.myReports,
    AppDrawerDestination.notifications,
    AppDrawerDestination.profile,
  ];
}

  String _label(AppDrawerDestination destination) {
    return switch (destination) {
      AppDrawerDestination.dashboard => 'Dashboard',
      AppDrawerDestination.exploreReports => 'Explore Reports',
      AppDrawerDestination.createReport => 'Report an Issue',
      AppDrawerDestination.myReports => 'My Reports',
      AppDrawerDestination.reportQueue => 'Report Queue',
      AppDrawerDestination.manageReports => 'Manage Reports',
      AppDrawerDestination.notifications => 'Notifications',
      AppDrawerDestination.profile => 'Profile',
    };
  }

  IconData _icon(AppDrawerDestination destination) {
    return switch (destination) {
      AppDrawerDestination.dashboard => Icons.dashboard_outlined,
      AppDrawerDestination.exploreReports => Icons.travel_explore_outlined,
      AppDrawerDestination.createReport => Icons.add_circle_outline,
      AppDrawerDestination.myReports => Icons.description_outlined,
      AppDrawerDestination.reportQueue => Icons.pending_actions_outlined,
      AppDrawerDestination.manageReports => Icons.assignment_outlined,
      AppDrawerDestination.notifications => Icons.notifications_outlined,
      AppDrawerDestination.profile => Icons.person_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final visibleDestinations = _destinations.where((destination) {
      return enabledDestinations == null ||
          enabledDestinations!.contains(destination);
    }).toList();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              accountName: Text(userName),
              accountEmail: Text(userEmail ?? ''),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  userName.trim().isNotEmpty
                      ? userName.trim()[0].toUpperCase()
                      : '?',
                ),
              ),
              otherAccountsPictures: [
                Icon(
                  role == UserRole.official
                      ? Icons.verified_user_outlined
                      : Icons.person_outline,
                ),
              ],
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final destination in visibleDestinations)
                    ListTile(
                      leading: Icon(_icon(destination)),
                      title: Text(_label(destination)),
                      selected: selectedDestination == destination,
                      onTap: () {
                        Navigator.of(context).pop();
                        onDestinationSelected(destination);
                      },
                    ),
                ],
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.of(context).pop();
                onSignOut();
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

