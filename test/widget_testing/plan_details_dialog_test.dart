import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/blocs/my_plans/my_plans_bloc.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:firebase_proj/common_widgets/PlanDetails.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../mock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

Future<void> main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('PlanDetailsDialog displays correctly',
      (WidgetTester tester) async {
    final fakeFirestore = FakeFirebaseFirestore();

    final planRepository = PlansRepository(firestore: fakeFirestore);
    final collectionReference = fakeFirestore.collection('plans');

    final myPlansBloc = MyPlansBloc(firestore: fakeFirestore);

    final testUid = 'test_uid';
    final title = 'Test Plan';

    final Plan1 = await collectionReference.add({
      'title': title,
      'location': 'Test Location',
      'creator': testUid,
      'Public': "false"
    });

    final plans = await planRepository.getPlansByUid(testUid);

    final creatorData = {
      'name': 'John Doe',
      'profilePictureUrl': '',
    };
    final dayName = 'Monday';
    final time12Hour = '10:00 AM';
    final date = '2023-01-01';
    final description = 'Test plan description';
    final pendingNames = ['Hamza', 'Saad'];
    final approvedNames = ['Maaz', 'Ali'];
    final declinedNames = ['Adil'];
    final markerPosition = LatLng(0, 0);
    final index = 0;
    final friendDocs = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlanDetailsDialog(
            title: title,
            creatorData: creatorData,
            dayName: dayName,
            time12Hour: time12Hour,
            date: date,
            description: description,
            PendingNames: pendingNames,
            ApprovedNames: approvedNames,
            DeclinedNames: declinedNames,
            onMarkerPositionChanged: (LatLng newPosition) {},
            initialPosition: markerPosition,
            plans: plans,
            index: index,
            friendDocs: friendDocs,
            bloc: myPlansBloc,
            uid: testUid,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(title), findsOneWidget);
    expect(find.textContaining('Plan made by:'), findsOneWidget);
    expect(find.text("John Doe"), findsOneWidget);
    expect(
        find.text('Plan Date: $dayName $time12Hour - $date'), findsOneWidget);
    expect(find.text('Plan Location: Test Location'), findsOneWidget);
    expect(find.text('Details:'), findsOneWidget);
    expect(find.text(description), findsOneWidget);
    expect(find.text('View Location in Map'), findsOneWidget);
    expect(find.text('View Discussion'), findsOneWidget);
    expect(find.text('Delete Plan'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Declined'), findsOneWidget);
    expect(find.textContaining(pendingNames[0]), findsOneWidget);
    expect(find.textContaining(approvedNames[0]), findsOneWidget);
    expect(find.textContaining(declinedNames[0]), findsOneWidget);
  });
}
