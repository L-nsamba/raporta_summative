import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.operationStatus != current.operationStatus,
          listener: (context, state) {
            if (state.operationStatus == AuthOperationStatus.failure &&
                state.errorMessage != null) {
              AppSnackbar.show(
                context,
                message: state.errorMessage!,
                type: SnackbarType.error,
              );
            }
            if (state.operationStatus == AuthOperationStatus.success &&
                state.successMessage != null) {
              AppSnackbar.show(
                context,
                message: state.successMessage!,
                type: SnackbarType.success,
              );
            }
          },
          builder: (context, state) {
            final isBusy = state.operationStatus == AuthOperationStatus.loading;
            final email = state.user?.email ?? '';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: isBusy
                            ? null
                            : () => context.read<AuthBloc>().add(
                                AuthLogoutRequested(),
                              ),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Verify your email address',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(
                          text: 'We sent you a link to verify your email address ',
                        ),
                        TextSpan(
                          text: '($email).',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: isBusy
                          ? null
                          : () => context.read<AuthBloc>().add(
                              AuthEmailVerificationRequested(),
                            ),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          children: [
                            TextSpan(text: "Didn't receive email link? "),
                            TextSpan(
                              text: 'Resend Link',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  AppButton(
                    label: "I've verified my email",
                    isLoading: isBusy,
                    onPressed: isBusy
                        ? null
                        : () => context.read<AuthBloc>().add(
                            const AuthEmailVerificationCheckRequested(),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: isBusy
                          ? null
                          : () => context.read<AuthBloc>().add(
                              AuthLogoutRequested(),
                            ),
                      child: const Text('Sign out / Back to login'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
