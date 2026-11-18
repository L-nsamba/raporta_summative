import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:raporta_frontend_backend_implementation/core/widgets/app_button.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_state.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/widgets/location_picker_map.dart';

class ReportLocationStepPage extends StatefulWidget {
  const ReportLocationStepPage({super.key});

  @override
  State<ReportLocationStepPage> createState() => _ReportLocationStepPageState();
}

class _ReportLocationStepPageState extends State<ReportLocationStepPage> {
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();

    final description = context
        .read<ReportFormCubit>()
        .state
        .locationDescription;

    _locationController = TextEditingController(text: description);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _selectLocation(LatLng point) {
    final cubit = context.read<ReportFormCubit>();

    cubit.updateLocation(
      lat: point.latitude,
      lng: point.longitude,
      locationDescription: cubit.state.locationDescription,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ReportFormCubit, ReportFormState>(
      builder: ((context, state) {
        final cubit = context.read<ReportFormCubit>();
        final hasLocation = state.lat != null && state.lng != null;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Where is the issue?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Tap the map to mark the exact location '
              'of the issue.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 330,
              child: LocationPickerMap(
                selectedLat: state.lat,
                selectedLng: state.lng,
                enabled: !state.isBusy,
                onLocationSelected: _selectLocation,
              ),
            ),

            const SizedBox(height: 16),

            if (hasLocation)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),

                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selected: '
                        '${state.lat!.toStringAsFixed(5)}, '
                        '${state.lng!.toStringAsFixed(5)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),

                    IconButton(
                      tooltip: 'Clear selected location',
                      onPressed: state.isBusy
                          ? null
                          : () {
                              _locationController.clear();
                              cubit.clearSelectedLocation();
                            },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              )
            else
              Text(
                'No location selected yet.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _locationController,
              maxLines: 2,
              maxLength: 200,
              enabled: !state.isBusy,
              decoration: const InputDecoration(
                labelText: 'Location description',
                hintText: 'e.g Near the roundabout, opposite the market',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: cubit.updateLocationDescription,
            ),
            const SizedBox(height: 8),

            Text(
              'Include a nearby landmark so officials '
              'can identify the location more easily. ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],

            const SizedBox(height: 24),

            AppButton(
              label: 'Continue to Review',
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
