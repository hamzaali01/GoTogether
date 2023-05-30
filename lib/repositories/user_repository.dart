import 'dart:math';

import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';

class UserRepository {
  UserRepository({required this.firestore});

  final FirebaseFirestore firestore;
  CollectionReference get usersCollection => firestore.collection('users');

  // final CollectionReference usersCollection =
  //     FirebaseFirestore.instance.collection('users');

  Future<List<DocumentSnapshot>> getFriendsByUid(String uid) async {
    final userDoc = await usersCollection.doc(uid).get();
    final friends =
        userDoc['friends'] != null ? List<String>.from(userDoc['friends']) : [];

    if (friends.isEmpty) {
      return [];
    }
    final friendDocs = await usersCollection
        .where(FieldPath.documentId, whereIn: friends)
        .get();

    return friendDocs.docs;
  }

  Future<void> createUser({required user, required name}) async {
    try {
      String username = await generateUniqueUsername();
      if (user!.uid != "test_uid") {
        await user!.updateDisplayName(name);
      }

      await usersCollection.doc(user!.uid).set({
        'name': name,
        'username': username,
        'friends': [],
        'profilePictureUrl': "",
        'plans': {
          'MyPlans': [],
          'ApprovedPlans': [],
          'DeclinedPlans': [],
          'PendingPlans': [],
        },
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> generateUniqueUsername() async {
    var random = Random();
    var username = '';
    var usernameExists = true;

    // Generate random username and check if it already exists in database
    while (usernameExists) {
      username =
          randomAlphaNumeric(8); // generate a 10-character alphanumeric string
      var snapshot =
          await usersCollection.where('username', isEqualTo: username).get();
      usernameExists = snapshot.docs.isNotEmpty;
    }

    return username;
  }

  Future<String> addFriend(String friend_username, String uid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('users')
          .where('username', isEqualTo: friend_username)
          .get();

      if (querySnapshot.size == 1) {
        final friendUid = querySnapshot.docs[0].id;

        // add friendUid to current user's friends array
        await usersCollection.doc(uid).update({
          'friends': FieldValue.arrayUnion([friendUid])
        });

        // add current user's uid to friend's friends array
        await usersCollection.doc(friendUid).update({
          'friends': FieldValue.arrayUnion([uid])
        });

        return "Friend Added Successfully";
      } else {
        return "Friend Not Found";
      }
    } catch (e) {
      return "Error";
    }
  }

  Future<DocumentSnapshot> getUserById(String uid) async {
    final userDoc = await usersCollection.doc(uid).get();
    //print(userDoc['username']);
    return userDoc;
  }
}
