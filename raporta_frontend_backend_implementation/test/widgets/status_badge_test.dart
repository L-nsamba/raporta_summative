import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raporta_frontend_backend_implementation/core/widgets/status_badge.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';

void main() {
  Future<void> pumpStatusBadge(WidgetTester tester, ReportStatus status) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: StatusBadge(status: status)),
        ),
      ),
    );
  }

  testWidgets('renders pending status correctly', (WidgetTester tester) async {
    await pumpStatusBadge(tester, ReportStatus.pending);

    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
  });

  testWidgets('renders under review status correctly', (
    WidgetTester tester,
  ) async {
    await pumpStatusBadge(tester, ReportStatus.underReview);

    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text('Under Review'), findsOneWidget);
  });

  testWidgets('renders forwarded status correctly', (
    WidgetTester tester,
  ) async {
    await pumpStatusBadge(tester, ReportStatus.forwarded);

    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text('Forwarded'), findsOneWidget);
  });

  testWidgets('renders resolved status correctly', (WidgetTester tester) async {
    await pumpStatusBadge(tester, ReportStatus.resolved);

    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
  });

  testWidgets('renders declined status correctly', (WidgetTester tester) async {
    await pumpStatusBadge(tester, ReportStatus.declined);

    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text('Declined'), findsOneWidget);
  });
}
