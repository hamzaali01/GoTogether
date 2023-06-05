import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:firebase_proj/screens/public_plans.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../mock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

Future<void> main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Public Plans should work correctly',
      (WidgetTester tester) async {
    final fakeFirestore = FakeFirebaseFirestore();

    final usersCollectionReference = fakeFirestore.collection('users');

    final plansRepository = PlansRepository(firestore: fakeFirestore);

    final testUid = 'test_uid';
    // final friendPlan2 =
    //     await collectionReference.add({'title': 'Friend Plan 2'});
// final friendPlan1 =
//         await collectionReference.add({'title': 'Friend Plan 1'});

    await usersCollectionReference.doc(testUid).set({
      'plans': {
        'PendingPlans': [],
        'ApprovedPlans': [],
        'DeclinedPlans': [],
        'MyPlans': []
      }
    });

    final testTitle = 'Public Plan 1';
    final testLocation = 'Karachi';
    final testMapLocation = LatLng(0, 0);
    final testDescription = 'Test Description';
    final testDateTime = '2023-05-26';
    final testIsPublic = 'true';
    final List<String> testSelectedFriends = [];

    final result = await plansRepository.createPlan(
      testUid,
      testTitle,
      testLocation,
      testMapLocation,
      testDescription,
      testDateTime,
      testIsPublic,
      testSelectedFriends,
    );

    expect(result, 'Success');

    await tester.pumpWidget(GetMaterialApp(
      home: PublicPlans(
        uid: testUid,
        firestore: fakeFirestore,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(Card), findsOneWidget);

    expect(find.text("Public Plan 1"), findsOneWidget);

    expect(find.text("You have no Plans here!"), findsNothing);
    expect(find.text("People Going: 1"), findsNothing);
    expect(find.text("People Going: 0"), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(1));

    expect(find.byIcon(Icons.search), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));

    await tester.pumpAndSettle();

    expect(find.text("Search by location..."), findsOneWidget);

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, "Lahore");
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNothing);

    await tester.enterText(searchField, "Karachi");
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsOneWidget);

    final GoingBtn = find.text("Going");
    await tester.tap(GoingBtn);
    await tester.pumpAndSettle();
    expect(find.text("People Going: 0"), findsNothing);
    expect(find.text("People Going: 1"), findsOneWidget);

    final NotGoingBtn = find.text("Not Going");
    await tester.tap(NotGoingBtn);
    await tester.pumpAndSettle();
    expect(find.text("People Going: 1"), findsNothing);
    expect(find.text("People Going: 0"), findsOneWidget);
  });
}
