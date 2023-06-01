import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_proj/screens/friends_plans.dart';
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

  testWidgets('Friends Plan should work correctly',
      (WidgetTester tester) async {
    final fakeFirestore = FakeFirebaseFirestore();

    final collectionReference = fakeFirestore.collection('plans');

    final usersCollectionReference = fakeFirestore.collection('users');

    final plansRepository = PlansRepository(firestore: fakeFirestore);

    final testUid = 'qf3ZAicM1ldmHPauNXYGA6ncvYl2';
    final testFriendUid = 'test_friend_uid';

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
    await usersCollectionReference.doc(testFriendUid).set({
      'plans': {
        'PendingPlans': [],
        'ApprovedPlans': [],
        'DeclinedPlans': [],
        'MyPlans': []
      }
    });

    final friendtestUid = testFriendUid;
    final testTitle = 'Friend Plan 1';
    final testLocation = 'Test Location';
    final testMapLocation = LatLng(0, 0);
    final testDescription = 'Test Description';
    final testDateTime = '2023-05-26';
    final testIsPublic = 'false';
    final testSelectedFriends = [testUid];

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
      home: FriendsPlans(
        uid: "qf3ZAicM1ldmHPauNXYGA6ncvYl2",
        firestore: fakeFirestore,
      ),
    ));

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byType(Plans), findsOneWidget);
    //expect(find.byType(Plans), findsNWidgets(3));

    expect(find.text("Pending"), findsOneWidget);
    expect(find.text("Approved"), findsOneWidget);
    expect(find.text("Declined"), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text("Friend Plan 1"), findsOneWidget);
    expect(find.text("You have no Plans here!"), findsNothing);

    final firstTab = find.text("Pending").first;
    final secondTab = find.text("Approved").first;
    final thirdTab = find.text("Declined").first;
    await tester.tap(secondTab);

    await tester.pumpAndSettle();

    expect(find.text("You have no Plans here!"), findsOneWidget);

    await tester.tap(thirdTab);

    await tester.pumpAndSettle();

    expect(find.text("You have no Plans here!"), findsOneWidget);

    await tester.tap(firstTab);

    await tester.pumpAndSettle();

    expect(find.text("Approve"), findsOneWidget);
    expect(find.text("Decline"), findsOneWidget);

    final approveBtn = find.text("Approve");

    await tester.tap(approveBtn);
    await tester.pumpAndSettle();
    expect(find.text("You have no Plans here!"), findsOneWidget);

    await tester.tap(secondTab);

    await tester.pumpAndSettle();

    expect(find.text("Friend Plan 1"), findsOneWidget);
    expect(find.text("You have no Plans here!"), findsNothing);
    expect(find.text("Decline"), findsOneWidget);
    final declineBtn = find.text("Decline");

    await tester.tap(declineBtn);
    await tester.pumpAndSettle();
    expect(find.text("You have no Plans here!"), findsOneWidget);

    await tester.tap(thirdTab);

    await tester.pumpAndSettle();

    expect(find.text("Friend Plan 1"), findsOneWidget);
    expect(find.text("You have no Plans here!"), findsNothing);
    expect(find.text("Approve"), findsOneWidget);
  });
}
