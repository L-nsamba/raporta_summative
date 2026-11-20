import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:raporta_frontend_backend_implementation/app/dependency_injection/injection_container.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/widgets/info_row.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/widgets/message_view.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/widgets/report_photo.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/widgets/section_tile.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/widgets/status_information.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/widgets/upvote_section.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/report_details_cubit.dart';
import '../cubit/report_details_state.dart';

class ReportDetailsPage extends StatelessWidget {
  final String reportId;

  const ReportDetailsPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view this report.')),
      );
    }

    return BlocProvider<ReportDetailsCubit>(
      create: (_) =>
          sl<ReportDetailsCubit>()
            ..loadReportDetails(reportId: reportId, userId: user.userId),
      child: _ReportDetailsView(reportId: reportId, userId: user.userId),
    );
  }
}

class _ReportDetailsView extends StatelessWidget {
  final String reportId;
  final String userId;

  const _ReportDetailsView({required this.reportId, required this.userId});

  Future<void> _refresh(BuildContext context) async {
    await context.read<ReportDetailsCubit>().refreshReportDetails(
      reportId: reportId,
      userId: userId,
    );
  }

  Future<void> _toggleUpvote(BuildContext context) async {
    await context.read<ReportDetailsCubit>().toggleReportUpvote(userId: userId);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatName(String value) {
    if (value.isEmpty) return value;

    final formatted = value.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh report',
            icon: const Icon(Icons.refresh),
            onPressed: () => _refresh(context),
          ),
        ],
      ),
      body: BlocBuilder<ReportDetailsCubit, ReportDetailsState>(
        builder: (context, state) {
          switch (state.status) {
            case ReportDetailsStatus.initial:
            case ReportDetailsStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case ReportDetailsStatus.notFound:
              return MessageView(
                icon: Icons.search_off_outlined,
                title: 'Report not found',
                message: 'This report may have been removed or is unavailable.',
                onRetry: () => _refresh(context),
              );

            case ReportDetailsStatus.failure:
              return MessageView(
                icon: Icons.error_outline,
                title: 'Unable to load report',
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () => _refresh(context),
              );

            case ReportDetailsStatus.loaded:
              final report = state.report;

              if (report == null) {
                return MessageView(
                  icon: Icons.info_outline,
                  title: 'Report unavailable',
                  message: 'No report details were returned.',
                  onRetry: () => _refresh(context),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _refresh(context),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    ReportPhoto(photoUrl: report.photoUrl),

                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _formatName(report.category.name),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: report.status),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SectionTitle(title: 'Description'),
                    const SizedBox(height: 8),
                    Text(
                      report.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    const SizedBox(height: 24),

                    SectionTitle(title: 'Location'),
                    const SizedBox(height: 12),

                    InfoRow(
                      icon: Icons.location_city_outlined,
                      label: 'Area',
                      value: _formatName(report.areaId),
                    ),

                    const SizedBox(height: 12),

                    InfoRow(
                      icon: Icons.place_outlined,
                      label: 'Specific location',
                      value: report.locationDescription.trim().isEmpty
                          ? 'Not provided'
                          : report.locationDescription,
                    ),

                    const SizedBox(height: 12),

                    InfoRow(
                      icon: Icons.my_location_outlined,
                      label: 'Coordinates',
                      value:
                          '${report.lat.toStringAsFixed(6)}, '
                          '${report.lng.toStringAsFixed(6)}',
                    ),

                    const SizedBox(height: 24),

                    SectionTitle(title: 'Report Information'),
                    const SizedBox(height: 12),

                    InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date submitted',
                      value: _formatDate(report.createdAt),
                    ),

                    const SizedBox(height: 12),

                    InfoRow(
                      icon: Icons.update_outlined,
                      label: 'Last updated',
                      value: _formatDate(report.updatedAt),
                    ),

                    const SizedBox(height: 24),

                    StatusInformation(report: report),

                    if (report.status.isPublic) ...[
                      const SizedBox(height: 24),
                      UpvoteSection(
                        upvoteCount: state.upvotes.length,
                        hasUpvoted: state.hasUpvoted,
                        isUpvoting: state.isUpvoting,
                        onPressed: () => _toggleUpvote(context),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
