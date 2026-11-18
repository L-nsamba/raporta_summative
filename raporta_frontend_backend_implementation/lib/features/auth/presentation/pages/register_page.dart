import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/dependency_injection/injection_container.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../areas/presentation/bloc/areas_cubit.dart';
import '../../../areas/presentation/bloc/areas_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AreasCubit>()..fetchAreas(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedAreaId;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAreaId == null) {
      AppSnackbar.show(
        context,
        message: 'Please select your area.',
        type: SnackbarType.error,
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        areaId: _selectedAreaId!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
            previous.operationStatus != current.operationStatus,
          listener: (context, state) {
            if (state.operationStatus == AuthOperationStatus.failure && state.errorMessage != null) {
              AppSnackbar.show(
                context,
                message: state.errorMessage!,
                type: SnackbarType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state.operationStatus == AuthOperationStatus.loading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create An Account',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    AppTextField(
                      label: '',
                      hint: 'Test Citizen',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    AppTextField(
                      label: '',
                      hint: 'test@citizen.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        
                        if (email.isEmpty) {
                          return 'Please enter your email.';
                        }
                        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                        if (!emailRegex.hasMatch(email)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    AppTextField(
                      label: '',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (value) {
                        // matches Firebases's defaule minimum password length.
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    AppTextField(
                      label: '',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword,
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    const Text('Area', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    BlocBuilder<AreasCubit, AreasState> (
                      builder: (context, areasState) {
                        if (areasState.status == AreasStatus.loading || areasState.status == AreasStatus.initial) {
                          return const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }

                        if (areasState.status == AreasStatus.failure) {
                          return Text(
                            areasState.errorMessage ?? 'Unable to load areas. Please try again.',
                            style: const TextStyle(color: AppColors.error),
                          );
                        }

                        if (areasState.areas.isEmpty) {
                          return const Text('No areas are available right now.');
                        }

                        return DropdownButtonFormField<String>(
                          initialValue: _selectedAreaId,
                          decoration: InputDecoration(
                            hintText: 'Please select an area.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: areasState.areas
                            .map(
                              (area) => DropdownMenuItem(
                                value: area.areaId,
                                child: Text(area.name),
                              ),
                            )
                            .toList(),
                          onChanged: (value) => setState(() => _selectedAreaId = value),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Sign Up',
                      isLoading: isLoading,
                      onPressed: () => _submit(context),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go(RouteNames.login),
                        child: const Text('Have an account already? Log in'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}