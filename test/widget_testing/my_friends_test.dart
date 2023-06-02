import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:firebase_proj/screens/my_friends.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../mock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

Future<void> main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('My Friends Screen should work correctly',
      (WidgetTester tester) async {
    final fakeFirestore = FakeFirebaseFirestore();

    final collectionReference = fakeFirestore.collection('plans');

    final usersCollectionReference = fakeFirestore.collection('users');

    final plansRepository = PlansRepository(firestore: fakeFirestore);

    final testUid = 'test_uid';
    final testFriendUid = 'test_friend_uid';

    await usersCollectionReference.doc(testUid).set({
      'name': 'Hamza',
      'username': 'hamza123',
      'profilePictureUrl': '',
      'friends': []
    });
    await usersCollectionReference.doc(testFriendUid).set({
      'name': 'Zarish',
      'username': 'zarish123',
      'profilePictureUrl': '',
      'friends': []
    });

    await tester.pumpWidget(GetMaterialApp(
      home: MyFriends(
        uid: testUid,
        firestore: fakeFirestore,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);

    expect(find.byType(Card), findsNothing);
    expect(find.text("Enter Friend's Username"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    final textfield = find.byType(TextField);
    final addFriendBtn = find.byType(ElevatedButton);

    await tester.enterText(textfield, "zarish123");
    await tester.tap(addFriendBtn);
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsOneWidget);
    expect(find.text("Zarish"), findsOneWidget);
  });
}
