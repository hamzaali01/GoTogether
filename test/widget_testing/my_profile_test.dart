import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/blocs/auth/auth_bloc.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:firebase_proj/screens/create_plan.dart';
import 'package:firebase_proj/screens/my_plans.dart';
import 'package:firebase_proj/screens/my_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  final fakeFirestore = FakeFirebaseFirestore();

  final collectionReference = fakeFirestore.collection('plans');

  final usersCollectionReference = fakeFirestore.collection('users');

  final plansRepository = PlansRepository(firestore: fakeFirestore);

  final testUid = 'test_uid';
  final testFriendUid = 'test_friend_uid';

  testWidgets('Public Plans should display correctly',
      (WidgetTester tester) async {
    await usersCollectionReference.doc(testUid).set({
      'plans': {
        'PendingPlans': [],
        'ApprovedPlans': [],
        'DeclinedPlans': [],
        'MyPlans': []
      },
      'friends': [testFriendUid],
      'username': 'hamza123',
      'name': 'Mir Hamza Ali',
      'profilePictureUrl': ''
    });

    await tester.pumpWidget(GetMaterialApp(
      home: BlocProvider(
        create: (context) => AuthBloc(),
        child: MyProfile(
          uid: testUid,
          firestore: fakeFirestore,
        ),
      ),
    ));

    // await tester.pumpAndSettle();

    // expect(find.byType(CircleAvatar), findsOneWidget);

    // expect(find.text('Mir Hamza Ali'), findsOneWidget);
    // expect(find.text('hamza123'), findsNothing);
  });
}
