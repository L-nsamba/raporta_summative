import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _goToLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.login);
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthPasswordResetRequested(email: _emailController.text.trim()),
    );
  }

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
                state.successMessage == 'Password reset email sent.') {
              setState(() => _resetEmailSent = true);
              AppSnackbar.show(
                context,
                message: state.successMessage!,
                type: SnackbarType.success,
              );
            }
          },
          builder: (context, state) {
            final isLoading =
                state.operationStatus == AuthOperationStatus.loading;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: () => _goToLogin(context),
                    icon: const Icon(Icons.arrow_back),
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reset password',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We will email you a link to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  if (!_resetEmailSent) ...[
                    Form(
                      key: _formKey,
                      child: AppTextField(
                        label: 'Email',
                        hint: 'example@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Please enter your email.';
                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );
                          if (!emailRegex.hasMatch(email)) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Send reset link',
                      isLoading: isLoading,
                      onPressed: () => _submit(context),
                    ),
                  ] else ...[
                    const Icon(Icons.mark_email_read_outlined, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Check your inbox for the reset link.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Back to Login',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _goToLogin(context),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
