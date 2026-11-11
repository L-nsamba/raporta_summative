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
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          return previous.user?.userId != current.user?.userId;
        },
        listener: (context, state) {
          context.read<PreferencesCubit>().loadPreferences();
        },
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
