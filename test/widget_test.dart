import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:f6_congviec/main.dart';

void main() {
  testWidgets('Full interaction test across all features', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 1. Open drawer and select Thống kê
    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openDrawer();
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(
      of: find.byType(NavigationDrawer),
      matching: find.text('Thống kê'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('công việc đã hoàn thành'), findsOneWidget);

    // 2. Tap bottom nav back to Việc
    await tester.tap(find.text('Việc'));
    await tester.pumpAndSettle();

    // 3. Tap FAB to open add dialog, test empty validation, then add item
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();
    expect(find.text('Không được để trống'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Việc mới');
    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();
    expect(find.text('Việc mới'), findsOneWidget);

    // 4. Tap cancel on add dialog
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
  });
}
