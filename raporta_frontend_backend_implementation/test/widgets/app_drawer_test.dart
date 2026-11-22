import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raporta_frontend_backend_implementation/core/widgets/app_drawer.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/user_role.dart';

void main() {
  Future<void> openDrawer(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
  }

  testWidgets('citizen sees the correct navigation options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          drawer: AppDrawer(
            role: UserRole.citizen,
            userName: 'Test Citizen',
            userEmail: 'citizen@example.com',
            onDestinationSelected: (_) {},
            onSignOut: () {},
          ),
        ),
      ),
    );

    await openDrawer(tester);

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Explore Reports'), findsOneWidget);
    expect(find.text('Report an Issue'), findsOneWidget);
    expect(find.text('My Reports'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    expect(find.text('Report Queue'), findsNothing);
    expect(find.text('Manage Reports'), findsNothing);
  });

  testWidgets('official sees the correct navigation options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          drawer: AppDrawer(
            role: UserRole.official,
            userName: 'Test Official',
            userEmail: 'official@example.com',
            onDestinationSelected: (_) {},
            onSignOut: () {},
          ),
        ),
      ),
    );

    await openDrawer(tester);

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Report Queue'), findsOneWidget);
    expect(find.text('Manage Reports'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);

    expect(find.text('Report an Issue'), findsNothing);
    expect(find.text('My Reports'), findsNothing);
  });

  testWidgets('selecting Profile invokes the correct callback', (
    WidgetTester tester,
  ) async {
    AppDrawerDestination? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          drawer: AppDrawer(
            role: UserRole.citizen,
            userName: 'Test Citizen',
            onDestinationSelected: (destination) {
              selectedDestination = destination;
            },
            onSignOut: () {},
          ),
        ),
      ),
    );

    await openDrawer(tester);

    await tester.ensureVisible(find.text('Profile'));
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(selectedDestination, AppDrawerDestination.profile);
  });

  testWidgets('tapping Sign Out invokes the sign-out callback', (
    WidgetTester tester,
  ) async {
    bool signOutRequested = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          drawer: AppDrawer(
            role: UserRole.citizen,
            userName: 'Test Citizen',
            onDestinationSelected: (_) {},
            onSignOut: () {
              signOutRequested = true;
            },
          ),
        ),
      ),
    );

    await openDrawer(tester);

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    expect(signOutRequested, true);
  });
}