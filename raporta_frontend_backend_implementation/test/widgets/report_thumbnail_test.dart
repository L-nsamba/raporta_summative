import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raporta_frontend_backend_implementation/core/widgets/report_thumbnail.dart';

void main() {
  group('ReportThumbnail Widget Tests', () {
    testWidgets('displays placeholder when photoUrl is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportThumbnail(photoUrl: null)),
        ),
      );

      expect(find.text('No photo'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('displays placeholder when photoUrl is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportThumbnail(photoUrl: '')),
        ),
      );

      expect(find.text('No photo'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('displays placeholder when photoUrl contains whitespace', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportThumbnail(photoUrl: '   ')),
        ),
      );

      expect(find.text('No photo'), findsOneWidget);
    });
  });
}
