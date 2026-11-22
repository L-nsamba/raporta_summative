import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raporta_frontend_backend_implementation/app/dependency_injection/injection_container.dart';
import 'package:raporta_frontend_backend_implementation/app/router/app_router.dart';
import 'package:raporta_frontend_backend_implementation/core/theme/app_theme.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_event.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_state.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/presentation/bloc/preferences_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/presentation/bloc/preferences_state.dart';
import 'package:raporta_frontend_backend_implementation/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/notifications/presentation/bloc/notifications_event.dart';

class RaportaApp extends StatelessWidget {
  const RaportaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),

        BlocProvider<PreferencesCubit>(
          create: (_) => sl<PreferencesCubit>()..loadPreferences(),
        ),

        BlocProvider<NotificationsBloc>(create: (_) => sl<NotificationsBloc>()),
      ],

      child: MultiBlocListener(
        listeners: [
          // Reload account-specific preferences when
          // the authenticated user changes.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                previous.user?.userId != current.user?.userId,
            listener: (context, state) {
              final userId = state.user?.userId;
              if (userId != null) {
                context.read<NotificationsBloc>().add(
                  NotificationsStarted(userId),
                );
              }
            },
          ),

          // Reevaluate navigation when authentication
          // or verification status changes.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) {
              return previous.status != current.status ||
                  previous.user?.userId != current.user?.userId ||
                  previous.isEmailVerified != current.isEmailVerified ||
                  previous.user?.role != current.user?.role;
            },
            listener: (context, state) {
              AppRouter.router.refresh();
            },
          ),
        ],

        child: BlocBuilder<PreferencesCubit, PreferencesState>(
          buildWhen: (previous, current) =>
              previous.preferences.isDarkMode != current.preferences.isDarkMode,

          builder: (context, state) {
            return MaterialApp.router(
              title: 'Raporta',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: state.preferences.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
