import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raporta_frontend_backend_implementation/core/widgets/app_button.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_state.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/widgets/category_selector.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/widgets/photo_picker_field.dart';

class ReportDetailsStepPage extends StatefulWidget {
  const ReportDetailsStepPage({super.key});

  @override
  State<ReportDetailsStepPage> createState() => _ReportDetailsStepPageState();
}

class _ReportDetailsStepPageState extends State<ReportDetailsStepPage> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    final description = context.read<ReportFormCubit>().state.description;

    _descriptionController = TextEditingController(text: description);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportFormCubit, ReportFormState>(
      builder: ((context, state) {
        final cubit = context.read<ReportFormCubit>();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Report Details',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Tell us about the issue you noticed.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 28),

            CategorySelector(
              selectedCategory: state.category,
              enabled: !state.isBusy,
              onChanged: cubit.updateCategory,
            ),

            const SizedBox(height: 22),

            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 1000,
              enabled: !state.isBusy,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the issue in detail...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              onChanged: cubit.updateDescription,
            ),

            const SizedBox(height: 16),

            PhotoPickerField(
              photoPath: state.photoPath,
              photoUrl: state.photoUrl,
              enabled: !state.isBusy,
              onPhotoSelected: cubit.updatePhotoPath,
              onPhotoRemoved: cubit.removePhoto,
            ),

            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 28),

            AppButton(
              label: 'Continue',
              onPressed: state.isBusy ? null : cubit.nextStep,
              isLoading: state.isBusy,
            ),

            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }
}
