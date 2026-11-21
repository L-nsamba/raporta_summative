import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../widgets/notifications_view.dart';

class OfficialNotificationsPage extends StatelessWidget {
  const OfficialNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthBloc>().state.user?.userId ?? '';

    return BlocProvider(
      create: (_) => sl<NotificationsBloc>()..add(NotificationsStarted(userId)),
      child: const NotificationsView(title: 'Notifications', isOfficial: true),
    );
  }
}