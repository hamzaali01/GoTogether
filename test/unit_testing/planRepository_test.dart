import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../mock.dart';

Future<void> main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  test('Get plans by UID', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    final plansRepository = PlansRepository(firestore: fakeFirestore);

    final collectionReference = fakeFirestore.collection('plans');

    final testUid = 'test_uid';

    await collectionReference.add({'creator': testUid, 'title': 'Plan 1'});
    await collectionReference.add({'creator': testUid, 'title': 'Plan 2'});
    await collectionReference.add({'creator': 'other_uid', 'title': 'Plan 3'});

    final plansByUid = await plansRepository.getPlansByUid(testUid);

    expect(plansByUid.length, 2);

    expect(plansByUid[0]['title'], 'Plan 1');
    expect(plansByUid[1]['title'], 'Plan 2');
  });

  test('Get friends plans', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    final plansRepository = PlansRepository(firestore: fakeFirestore);

    final collectionReference = fakeFirestore.collection('plans');

    final usersCollectionReference = fakeFirestore.collection('users');

    final testUid = 'test_uid';
    final friendUid = 'friend_uid';

    final friendPlan1 =
        await collectionReference.add({'title': 'Friend Plan 1'});
    final friendPlan2 =
        await collectionReference.add({'title': 'Friend Plan 2'});

    await usersCollectionReference.doc(testUid).set({
      'plans': {
        'PendingPlans': [friendPlan1.id, friendPlan2.id]
      }
    });

    final friendsPlans =
        await plansRepository.getFriendsPlans(testUid, 'PendingPlans');

    expect(friendsPlans.length, 2);

    expect(friendsPlans[0]['title'], 'Friend Plan 1');
    expect(friendsPlans[1]['title'], 'Friend Plan 2');
  });

  test('Get Public plans', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    final plansRepository = PlansRepository(firestore: fakeFirestore);

    final collectionReference = fakeFirestore.collection('plans');

    await collectionReference.add({'Public': 'true', 'title': 'Plan 1'});
    await collectionReference.add({'Public': 'true', 'title': 'Plan 2'});
    await collectionReference.add({'Public': 'false', 'title': 'Plan 3'});

    final publicPlans = await plansRepository.getPublicPlans();

    expect(publicPlans.length, 2);

    expect(publicPlans[0]['title'], 'Plan 1');
    expect(publicPlans[1]['title'], 'Plan 2');
  });

  test('Update plan status', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    final plansRepository = PlansRepository(firestore: fakeFirestore);

    final plansCollectionReference = fakeFirestore.collection('plans');

    final usersCollectionReference = fakeFirestore.collection('users');

    final testUid = 'test_uid';
    final testPlanId = 'test_plan_id';
    final testStatus = 'ApprovedPlans';

    await plansCollectionReference.doc(testPlanId).set({
      'Invited': {
        'Pending': [testUid],
        'Approved': [],
        'Declined': []
      }
    });
    await usersCollectionReference.doc(testUid).set({
      'plans': {
        'PendingPlans': [testPlanId],
        'ApprovedPlans': [],
        'DeclinedPlans': []
      }
    });

    final result =
        await plansRepository.updatePlanStatus(testUid, testPlanId, testStatus);

    expect(result, 'Added Plan to Approved Plans');

    final updatedPlanSnapshot =
        await plansCollectionReference.doc(testPlanId).get();
    final updatedUserSnapshot =
        await usersCollectionReference.doc(testUid).get();

    expect(updatedPlanSnapshot.data()!['Invited']['Approved'], [testUid]);
    expect(updatedUserSnapshot.data()!['plans']['PendingPlans'], []);
    expect(updatedUserSnapshot.data()!['plans']['ApprovedPlans'], [testPlanId]);
  });

  test('Create plan', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    final plansRepository = PlansRepository(firestore: fakeFirestore);

    final plansCollectionReference = fakeFirestore.collection('plans');

    final usersCollectionReference = fakeFirestore.collection('users');

    final testUid = 'test_uid';
    final testTitle = 'Test Plan';
    final testLocation = 'Test Location';
    final testMapLocation = LatLng(0, 0);
    final testDescription = 'Test Description';
    final testDateTime = '2023-05-26';
    final testIsPublic = 'false';
    final testSelectedFriends = ['friend1_uid', 'friend2_uid'];

    await usersCollectionReference.doc(testUid).set({
      'plans': {
        'PendingPlans': [],
        'ApprovedPlans': [],
        'DeclinedPlans': [],
        'MyPlans': []
      }
    });
    await usersCollectionReference.doc(testSelectedFriends[0]).set({
      'plans': {
        'PendingPlans': [],
        'ApprovedPlans': [],
        'DeclinedPlans': [],
        'MyPlans': []
      }
    });
    await usersCollectionReference.doc(testSelectedFriends[1]).set({
      'plans': {
        'PendingPlans': [],
        'ApprovedPlans': [],
        'DeclinedPlans': [],
        'MyPlans': []
      }
    });

    // Call the createPlan function
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

    final querySnapshot = await plansCollectionReference.get();
    expect(querySnapshot.docs.length, 1);
    final createdPlanData = querySnapshot.docs.first.data();
    expect(createdPlanData['title'], testTitle);
    expect(createdPlanData['location'], testLocation);
    expect(createdPlanData['mapLocation'],
        GeoPoint(testMapLocation.latitude, testMapLocation.longitude));
    expect(createdPlanData['description'], testDescription);
    expect(createdPlanData['date'], testDateTime);
    expect(createdPlanData['Public'], testIsPublic);
    expect(createdPlanData['Invited']['Pending'],
        [testSelectedFriends[0], testSelectedFriends[1]]);
    expect(createdPlanData['creator'], testUid);

    final userSnapshot = await usersCollectionReference.doc(testUid).get();
    final userPlansData = userSnapshot.data()!['plans'];
    final createdPlanId = querySnapshot.docs.first.id;
    expect(userPlansData['MyPlans'], [createdPlanId]);
    expect(userPlansData['PendingPlans'], []);
    expect(userPlansData['ApprovedPlans'], []);

    final friend1Snapshot =
        await usersCollectionReference.doc('friend1_uid').get();
    final friend2Snapshot =
        await usersCollectionReference.doc('friend2_uid').get();
    final friend1PlansData = friend1Snapshot.data()!['plans'];
    final friend2PlansData = friend2Snapshot.data()!['plans'];
    expect(friend1PlansData['PendingPlans'], [createdPlanId]);
    expect(friend2PlansData['PendingPlans'], [createdPlanId]);
  });

  test('Delete plan and remove from users', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    final plansRepository = PlansRepository(firestore: fakeFirestore);

    final plansCollectionReference = fakeFirestore.collection('plans');

    final usersCollectionReference = fakeFirestore.collection('users');

    final testPlanId = 'test_plan_id';

    await plansCollectionReference.doc(testPlanId).set({});
    await usersCollectionReference.doc('user1_uid').set({
      'plans': {
        'MyPlans': [testPlanId]
      }
    });
    await usersCollectionReference.doc('user2_uid').set({
      'plans': {
        'MyPlans': [testPlanId]
      }
    });

    final result =
        await plansRepository.deletePlanAndRemoveFromUsers(testPlanId);

    expect(result, 'Successfully Deleted Plan');

    final deletedPlanSnapshot =
        await plansCollectionReference.doc(testPlanId).get();
    final user1Snapshot = await usersCollectionReference.doc('user1_uid').get();
    final user2Snapshot = await usersCollectionReference.doc('user2_uid').get();

    expect(deletedPlanSnapshot.exists, false);
    expect(user1Snapshot.data()!['plans']['MyPlans'], []);
    expect(user2Snapshot.data()!['plans']['MyPlans'], []);
  });
}
