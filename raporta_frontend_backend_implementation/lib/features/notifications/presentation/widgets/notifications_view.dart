import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import 'notification_tile.dart';

class NotificationsView extends StatelessWidget {
  final String title;
  final bool isOfficial;

  const NotificationsView({
    super.key,
    required this.title,
    required this.isOfficial,
  });

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _unreadLabel(int count) {
    if (isOfficial) {
      return 'You have $count notification${count == 1 ? '' : 's'} today.';
    }
    return 'You have $count unread notification${count == 1 ? '' : 's'}.';
  }

  void _onDrawerDestinationSelected(
    BuildContext context,
    AppDrawerDestination destination,
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
      case AppDrawerDestination.reportQueue:
        context.go(RouteNames.reportQueue);
      case AppDrawerDestination.notifications:
        context.go(isOfficial ? RouteNames.officialNotifications : RouteNames.notifications);
      case AppDrawerDestination.profile:
        context.go(RouteNames.profile);
    }
  }

  Widget _buildLoaded(
    BuildContext context,
    NotificationsState state,
    String userId,
  ) {
    if (state.notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none,
        title: "You're all caught up",
        message: 'New notifications will show up here.',
      );
    }

    final sorted = [...state.notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final todayItems = sorted.where((n) => _isToday(n.createdAt)).toList();
    final earlierItems = sorted.where((n) => !_isToday(n.createdAt)).toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationsBloc>().add(NotificationsStarted(userId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _unreadLabel(state.unreadCount),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          if (todayItems.isNotEmpty) ...[
            const Text('Today', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...todayItems.map(
              (notification) => NotificationTile(
                notification: notification,
                onTap: () => context
                    .read<NotificationsBloc>()
                    .add(NotificationMarkedRead(notification.notificationId)),
              ),
            ),
          ],
          if (earlierItems.isNotEmpty) ...[
            if (todayItems.isNotEmpty) const SizedBox(height: 16),
            const Text('Earlier', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...earlierItems.map(
              (notification) => NotificationTile(
                notification: notification,
                onTap: () => context
                    .read<NotificationsBloc>()
                    .add(NotificationMarkedRead(notification.notificationId)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final notificationsState = context.watch<NotificationsBloc>().state;

    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: AppDrawer(
        role: user.role,
        userName: user.name,
        userEmail: user.email,
        selectedDestination: AppDrawerDestination.notifications,
        onDestinationSelected: (destination) =>
            _onDrawerDestinationSelected(context, destination),
        onSignOut: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
      ),
      body: switch (notificationsState.status) {
        NotificationsStatus.initial ||
        NotificationsStatus.loading =>
          const LoadingIndicator(),
        NotificationsStatus.failure => EmptyState(
            icon: Icons.error_outline,
            title: 'Unable to load notifications',
            message: notificationsState.errorMessage ?? 'Please try again.',
            actionLabel: 'Retry',
            onAction: () => context
                .read<NotificationsBloc>()
                .add(NotificationsStarted(user.userId)),
          ),
        NotificationsStatus.loaded =>
          _buildLoaded(context, notificationsState, user.userId),
      },
    );
  }
}