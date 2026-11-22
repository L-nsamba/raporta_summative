import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection/injection_container.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../areas/presentation/bloc/areas_cubit.dart';
import '../../../areas/presentation/bloc/areas_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class EditAccountDialog extends StatelessWidget {
  const EditAccountDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const EditAccountDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AreasCubit>()..fetchAreas(),
      child: const _EditAccountCard(),
    );
  }
}

class _EditAccountCard extends StatefulWidget {
  const _EditAccountCard();

  @override
  State<_EditAccountCard> createState() => _EditAccountCardState();
}

class _EditAccountCardState extends State<_EditAccountCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String? _selectedAreaId;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _selectedAreaId = user?.areaId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, String existingAreaId, bool isOfficial) {
    if (!_formKey.currentState!.validate()) return;

    if (!isOfficial && _selectedAreaId == null) {
      AppSnackbar.show(
        context,
        message: 'Please select your area.',
        type: SnackbarType.error,
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthProfileUpdateRequested(
        name: _nameController.text.trim(),
        areaId: isOfficial ? existingAreaId : _selectedAreaId!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;

    if (user == null) return const SizedBox.shrink();

    final isOfficial = user.role == UserRole.official;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              state.successMessage == 'Profile updated successfully.') {
            AppSnackbar.show(
              context,
              message: state.successMessage!,
              type: SnackbarType.success,
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isLoading =
              state.operationStatus == AuthOperationStatus.loading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'My Account Editing',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    label: '',
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name.';
                      }
                      return null;
                    },
                  ),
                  if (!isOfficial) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Area',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<AreasCubit, AreasState>(
                      builder: (context, areasState) {
                        if (areasState.status == AreasStatus.loading ||
                            areasState.status == AreasStatus.initial) {
                          return const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }

                        if (areasState.status == AreasStatus.failure) {
                          return Text(
                            areasState.errorMessage ??
                                'Unable to load areas. Please try again.',
                            style: const TextStyle(color: AppColors.error),
                          );
                        }

                        if (areasState.areas.isEmpty) {
                          return const Text(
                            'No areas are available right now.',
                          );
                        }

                        return DropdownButtonFormField<String>(
                          initialValue: _selectedAreaId,
                          decoration: InputDecoration(
                            hintText: 'Please select an area',
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
                          onChanged: (value) =>
                              setState(() => _selectedAreaId = value),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Save changes',
                    isExpanded: false,
                    isLoading: isLoading,
                    onPressed: () => _submit(context, user.areaId, isOfficial),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
