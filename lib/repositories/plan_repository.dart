import 'dart:math';

import "package:firebase_auth/firebase_auth.dart";
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:google_sign_in/google_sign_in.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:latlong2/latlong.dart';

class PlansRepository {
  final CollectionReference plansCollection =
      FirebaseFirestore.instance.collection('plans');

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<List<DocumentSnapshot>> getPlansByUid(String uid) async {
    final querySnapshot = await plansCollection
        .where('creator', isEqualTo: uid)
        .orderBy('created_at', descending: true)
        .get();

    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> getPublicPlans() async {
    final snapshot =
        await plansCollection.where('Public', isEqualTo: "true").get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getFriendsPlans(
      String uid, String type) async {
    final userDoc = await usersCollection.doc(uid).get();
    final plans = userDoc['plans'] ?? {};
    final Plans = plans[type] ?? [];

    if (Plans.isEmpty) {
      return [];
    }

    final pendingPlanDocs = await plansCollection
        .where(FieldPath.documentId, whereIn: Plans)
        .get()
        .then((querySnapshot) => querySnapshot.docs);

    return pendingPlanDocs;
  }

  Future<String> updatePlanStatus(
      String uid, String planId, String status) async {
    try {
      final userDoc = usersCollection.doc(uid);

      await userDoc.update({
        'plans.PendingPlans': FieldValue.arrayRemove([planId])
      });

      if (status != '') {
        await userDoc.update({
          'plans.$status': FieldValue.arrayUnion([planId])
        });
      }

      if (status == "ApprovedPlans") {
        await userDoc.update({
          'plans.DeclinedPlans': FieldValue.arrayRemove([planId])
        });
      } else if (status == "DeclinedPlans") {
        await userDoc.update({
          'plans.ApprovedPlans': FieldValue.arrayRemove([planId])
        });
      } else if (status == "") {
        await userDoc.update({
          'plans.ApprovedPlans': FieldValue.arrayRemove([planId])
        });
        await userDoc.update({
          'plans.DeclinedPlans': FieldValue.arrayRemove([planId])
        });
      }

      final planDoc = plansCollection.doc(planId);
      final plan = await planDoc.get();
      final invited = plan['Invited'];

      invited['Pending'].remove(uid);
      invited['Approved'].remove(uid);
      invited['Declined'].remove(uid);

      if (status == "ApprovedPlans")
        invited['Approved'].add(uid);
      else if (status == "DeclinedPlans") invited['Declined'].add(uid);

      await planDoc.update({'Invited': invited});

      //final updatedPlanSnapshot = await planDoc.get();

      //return updatedPlanSnapshot;
      if (status == "ApprovedPlans") {
        return "Added Plan to Approved Plans";
      } else {
        return "Added Plan to Declined Plans";
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> createPlan(
      String uid,
      String title,
      String location,
      LatLng mapLocation,
      String? description,
      String DateTime,
      String IsPublic,
      List<String> selectedFriends) async {
    try {
      final userRef = usersCollection.doc(uid);
      final newPlanRef = await plansCollection.add({
        'title': title,
        'location': location,
        'mapLocation': GeoPoint(mapLocation.latitude, mapLocation.longitude),
        'description': description,
        'date': DateTime,
        'Public': IsPublic,
        'Invited': {
          'Pending': IsPublic == "false" ? selectedFriends : [],
          'Approved': [],
          'Declined': [],
        },
        'creator': uid,
        'created_at': FieldValue.serverTimestamp(),
      });

      final newPlanId = newPlanRef.id;

      await userRef.update({
        'plans.MyPlans': FieldValue.arrayUnion([newPlanId]),
      });

      if (IsPublic == "false") {
        for (final friendId in selectedFriends) {
          final friendDoc = usersCollection.doc(friendId);
          await friendDoc.update({
            'plans.PendingPlans': FieldValue.arrayUnion([newPlanId])
          });
        }
      }

      print('New plan added to MyPlans array in user document');
      return "Success";
    } catch (e) {
      return "Error";
    }
  }

  Future<String> deletePlanAndRemoveFromUsers(String planId) async {
    try {
      await plansCollection.doc(planId).delete();

      final usersSnapshot = await usersCollection.get();
      usersSnapshot.docs.forEach((userDoc) {
        final userData = userDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> plans = Map<String, dynamic>.from(
            userData['plans'] as Map<String, dynamic>);

        for (var category in plans.keys) {
          if (plans[category] is List<dynamic>) {
            plans[category] = (plans[category] as List<dynamic>).cast<String>();
          } else {
            plans[category] = [];
          }

          if (plans[category].contains(planId)) {
            plans[category].remove(planId);
          }
        }

        userDoc.reference.update({'plans': plans});
      });
      return "Successfully Deleted Plan";
    } catch (e) {
      //  print(e.toString());
      return e.toString();
    }
  }
}
