// This used to be Flutter's default "counter increments" demo test,
// generated when the project was first created. It tested MyApp() as
// if it were the stock counter app — but MyApp now boots the real
// FitHer app (SplashScreen -> AuthController -> Firebase, etc.), which
// isn't set up in a plain test environment, so it always failed.
//
// Testing the real app boot needs GetX bindings + Firebase mocked,
// which is more setup than a "basic" smoke test — that's deferred to a
// later, more detailed test pass (see test/data + test/widgets for the
// basic tests added so far). For now this file just confirms the test
// harness itself is wired up correctly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test harness sanity check — a basic widget renders',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('flutter test is working')),
      ),
    );

    expect(find.text('flutter test is working'), findsOneWidget);
  });
}
