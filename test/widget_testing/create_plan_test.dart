import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:firebase_proj/screens/create_plan.dart';
import 'package:firebase_proj/screens/my_plans.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../mock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

Future<void> main() async {
  group('CreatePlan Widget', () {
    setupFirebaseAuthMocks();

    setUpAll(() async {
      await Firebase.initializeApp();
    });

    final fakeFirestore = FakeFirebaseFirestore();

    final collectionReference = fakeFirestore.collection('plans');

    final usersCollectionReference = fakeFirestore.collection('users');

    final plansRepository = PlansRepository(firestore: fakeFirestore);

    final testUid = 'test_uid';
    final testFriendUid = 'test_friend_uid';

    testWidgets('Should be able to create a Plan with correct inputs',
        (WidgetTester tester) async {
      await usersCollectionReference.doc(testUid).set({
        'plans': {
          'PendingPlans': [],
          'ApprovedPlans': [],
          'DeclinedPlans': [],
          'MyPlans': []
        },
        'friends': [testFriendUid]
      });
      await usersCollectionReference.doc(testFriendUid).set({
        'name': 'Friend Name',
        'plans': {
          'PendingPlans': [],
          'ApprovedPlans': [],
          'DeclinedPlans': [],
          'MyPlans': []
        }
      });

      await tester.pumpWidget(GetMaterialApp(
        home: CreatePlan(
          uid: testUid,
          firestore: fakeFirestore,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(4));

      await tester.enterText(find.byType(TextFormField).first, 'Test Plan');
      await tester.enterText(find.byType(TextFormField).at(1), 'Test Location');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter the Title'), findsNothing);
      expect(find.text('Please enter Location'), findsNothing);
    });

    // testWidgets('Should show an error when creating a plan with invalid inputs',
    //     (WidgetTester tester) async {
    //   await usersCollectionReference.doc(testUid).set({
    //     'plans': {
    //       'PendingPlans': [],
    //       'ApprovedPlans': [],
    //       'DeclinedPlans': [],
    //       'MyPlans': []
    //     },
    //     'friends': [testFriendUid]
    //   });
    //   await usersCollectionReference.doc(testFriendUid).set({
    //     'name': 'Friend Name',
    //     'plans': {
    //       'PendingPlans': [],
    //       'ApprovedPlans': [],
    //       'DeclinedPlans': [],
    //       'MyPlans': []
    //     }
    //   });
    //   await tester.pumpWidget(GetMaterialApp(
    //     home: CreatePlan(
    //       uid: testUid,
    //       firestore: fakeFirestore,
    //     ),
    //   ));
    //   await tester.pumpAndSettle();

    //   expect(find.text('Create'), findsOneWidget);

    //   await tester.tap(find.text('Create'));
    //   await tester.pumpAndSettle();

    //   expect(find.text('Please enter the Title'), findsOneWidget);

    //   // expect(find.textContaining('Please enter the Title'), findsOneWidget);
    //   // expect(find.textContaining('Please enter Location'), findsOneWidget);
    // });
  });
}
