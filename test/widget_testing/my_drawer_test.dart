import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../mock.dart';

Future<void> main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('MyDrawer should work correctly', (WidgetTester tester) async {
    // await _auth.signInWithEmailAndPassword(
    //     email: "hamza@hotmail.com", password: "hamza123");

    await tester.pumpWidget(GetMaterialApp(
      home: MyDrawer(uid: "qf3ZAicM1ldmHPauNXYGA6ncvYl2"),
    ));

    expect(find.byType(Card), findsNWidgets(5));

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('My Plans'), findsOneWidget);
    expect(find.text('My Friends'), findsOneWidget);
    expect(find.text('Friends Plans'), findsOneWidget);
    expect(find.text('Public Events'), findsOneWidget);

    // final secondTab = find.text("Approved").first;
    await tester.tap(find.byType(Card).first);
  });
}
