import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/dependency_injection/injection_container.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../areas/domain/entities/area.dart';
import '../../../areas/presentation/bloc/areas_cubit.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/notification_toggle_tile.dart';
import '../widgets/theme_toggle_tile.dart';
import 'edit_account_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AreasCubit>()..fetchAreas(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  String _areaSubtitle(AppUser user, List<Area> areas) {
    if (user.role == UserRole.official) {
      if (areas.isEmpty) return 'Official';
      final names = areas.map((area) => area.name).join(' & ');
      return 'Official · $names';
    }

    for (final area in areas) {
      if (area.areaId == user.areaId) {
        return 'Citizen · ${area.name}';
      }
    }
    return 'Citizen';
  }

  void _onDrawerDestinationSelected(
    BuildContext context,
    AppDrawerDestination destination,
    bool isOfficial,
  ) {
    switch (destination) {
      case AppDrawerDestination.dashboard:
        context.go(isOfficial ? RouteNames.officialDashboard : RouteNames.citizenDashboard);
      case AppDrawerDestination.exploreReports:
        context.go(RouteNames.reports);
      case AppDrawerDestination.createReport:
        context.go(RouteNames.createReport);
      case AppDrawerDestination.myReports:
        context.go(RouteNames.myReports);
      case AppDrawerDestination.manageReports:
        context.go(RouteNames.assignedReports);
      case AppDrawerDestination.notifications:
        context.go(isOfficial ? RouteNames.officialNotifications : RouteNames.notifications);
      case AppDrawerDestination.profile:
        context.go(RouteNames.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final areasState = context.watch<AreasCubit>().state;

    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final isOfficial = user.role == UserRole.official;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      drawer: AppDrawer(
        role: user.role,
        userName: user.name,
        userEmail: user.email,
        selectedDestination: AppDrawerDestination.profile,
        onDestinationSelected: (destination) =>
            _onDrawerDestinationSelected(context, destination, isOfficial),
        onSignOut: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _areaSubtitle(user, areasState.areas),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: const Icon(Icons.person_outline, color: Colors.black87),
            ),
            title: const Text('My Account', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Edit your personal information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => EditAccountDialog.show(context),
          ),
          const NotificationToggleTile(),
          const ThemeToggleTile(),
          const Divider(height: 32),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: const Icon(Icons.logout, color: Colors.black87),
            ),
            title: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Exit your account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
          ),
        ],
      ),
    );
  }
}