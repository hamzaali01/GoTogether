import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:firebase_proj/screens/my_plans.dart';
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

  testWidgets('My Plans should work correctly', (WidgetTester tester) async {
    final fakeFirestore = FakeFirebaseFirestore();

    final collectionReference = fakeFirestore.collection('plans');

    final usersCollectionReference = fakeFirestore.collection('users');

    final plansRepository = PlansRepository(firestore: fakeFirestore);

    final testUid = 'qf3ZAicM1ldmHPauNXYGA6ncvYl2';
    final testFriendUid = 'test_friend_uid';

    await usersCollectionReference.doc(testUid).set({
      'plans': {
        'PendingPlans': [],
        'ApprovedPlans': [],
        'DeclinedPlans': [],
        'MyPlans': []
      }
    });
    await usersCollectionReference.doc(testFriendUid).set({
      'plans': {
        'PendingPlans': [],
        'ApprovedPlans': [],
        'DeclinedPlans': [],
        'MyPlans': []
      }
    });

    final friendtestUid = testUid;
    final testTitle = 'Friend Plan 1';
    final testLocation = 'Test Location';
    final testMapLocation = LatLng(0, 0);
    final testDescription = 'Test Description';
    final testDateTime = '2023-05-26';
    final testIsPublic = 'false';
    final testSelectedFriends = [friendtestUid];

    final result = await plansRepository.createPlan(
      friendtestUid,
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
      home: MyPlans(
        uid: "qf3ZAicM1ldmHPauNXYGA6ncvYl2",
        firestore: fakeFirestore,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(Card), findsOneWidget);

    expect(find.text("Friend Plan 1"), findsOneWidget);

    expect(find.text("You have no Plans here!"), findsNothing);
    expect(find.text("Invited: 0"), findsNothing);
    expect(find.text("Approved: 1"), findsNothing);
    expect(find.text("Declined: 1"), findsNothing);

    expect(find.text("Invited: 1"), findsOneWidget);
    expect(find.text("Approved: 0"), findsOneWidget);
    expect(find.text("Declined: 0"), findsOneWidget);
  });
}
