import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/repositories/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

class myUser {
  String uid;
  myUser(this.uid);
}

Future<void> main() async {
  setupFirebaseAuthMocks();
  late UserRepository userRepository;
  late FakeFirebaseFirestore fakeFirestore;
  // late CollectionReference collectionReference;

  setUp(() async {
    await Firebase.initializeApp();
    fakeFirestore = FakeFirebaseFirestore();
    userRepository = UserRepository(firestore: fakeFirestore);
    //collectionReference = fakeFirestore.collection('users');
  });

  test('Get friends by UID', () async {
    const testUid = 'test_uid';
    const friend1Uid = 'friend1_uid';
    const friend2Uid = 'friend2_uid';
    const friendIds = [friend1Uid, friend2Uid];

    final friend1Data = {'friends': friendIds};
    final friend2Data = {'friends': []};

    fakeFirestore.collection('users').doc(testUid).set(friend1Data);
    fakeFirestore.collection('users').doc(friend1Uid).set({});
    fakeFirestore.collection('users').doc(friend2Uid).set(friend2Data);

    final friends = await userRepository.getFriendsByUid(testUid);

    expect(friends.length, 2);
    expect(friends[0].id, friend1Uid);
    expect(friends[1].id, friend2Uid);
  });

  test('Create user', () async {
    myUser user = myUser("test_uid");
    await userRepository.createUser(user: user, name: 'John Doe');

    final userDocSnapshot =
        await fakeFirestore.collection('users').doc('test_uid').get();
    expect(userDocSnapshot.exists, true);
    expect(userDocSnapshot['name'], 'John Doe');
  });

  test('Generate unique username', () async {
    final username = await userRepository.generateUniqueUsername();

    expect(username, isNotEmpty);
  });

  test('Add friend', () async {
    const testUid = 'test_uid';
    const testUsername = 'test_username';
    const friendUid = 'friend_uid';
    const friendUsername = 'friend_username';

    await fakeFirestore
        .collection('users')
        .doc(testUid)
        .set({'friends': [], 'username': testUsername});
    await fakeFirestore
        .collection('users')
        .doc(friendUid)
        .set({'friends': [], 'username': friendUsername});

    final result = await userRepository.addFriend(friendUsername, testUid);

    expect(result, 'Friend Added Successfully');

    final userDocSnapshot =
        await fakeFirestore.collection('users').doc(testUid).get();
    final friendDocSnapshot =
        await fakeFirestore.collection('users').doc(friendUid).get();

    expect(userDocSnapshot['friends'], contains(friendUid));
    expect(friendDocSnapshot['friends'], contains(testUid));
  });

  test('Get user by ID', () async {
    const testUid = 'test_uid';
    const userData = {'name': 'John Doe'};

    fakeFirestore.collection('users').doc(testUid).set(userData);

    final userDocSnapshot = await userRepository.getUserById(testUid);

    expect(userDocSnapshot.exists, true);
    expect(userDocSnapshot['name'], 'John Doe');
  });
}
