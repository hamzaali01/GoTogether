import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_proj/blocs/friends_plans/friends_plan_bloc.dart';
import 'package:firebase_proj/blocs/my_plans/my_plans_bloc.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:firebase_proj/screens/login_register_page.dart';
import 'package:firebase_proj/screens/my_plans.dart';
import 'package:firebase_proj/screens/my_profile.dart';
import 'package:firebase_proj/widgets/PlanDetails.dart';
import 'package:firebase_proj/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_proj/screens/friends_plans.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import '../mock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

// class MockFirebaseAuth extends Mock implements Auth {}

// class MockFirebaseUser extends Mock implements User {}

// class MockPlanRepository extends Mock implements PlansRepository {}

// class MockFriendsPlanBloc extends Mock implements FriendsPlanBloc {}

Future<void> main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });
  // final mockPlanRepository = MockPlanRepository();
  // MockFirebaseAuth _auth = MockFirebaseAuth();

  testWidgets('Login Page should render correctly',
      (WidgetTester tester) async {
    // await _auth.signInWithEmailAndPassword(
    //     email: "hamza@hotmail.com", password: "hamza123");
    // Build the widget with authenticated user
    await tester.pumpWidget(GetMaterialApp(
      home: LoginPage(),
    ));

    expect(find.text('LOGIN'), findsOneWidget);
    var textFieldEmail = find.byKey(Key("EnterEmail"));
    await tester.enterText(textFieldEmail, "hamza@hotmail.com");
    var textFieldPassword = find.byKey(Key("EnterPassword"));
    await tester.enterText(textFieldPassword, "hamza123");

    //var RegisterInsteadButton = find.text("Register instead");
    var RegisterInsteadButton = find.byType(TextButton);
    await tester.tap(RegisterInsteadButton);

    await tester.pumpAndSettle();

    expect(find.text('REGISTER'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
    var textFieldName = find.byKey(Key("EnterName"));
    await tester.enterText(textFieldEmail, "Mir Hamza Ali");
    var textFieldConfirmPassword = find.byKey(Key("EnterConfirmPassword"));
    await tester.enterText(textFieldPassword, "hamza123");
    //  expect(find.text('LOGIN'), findsOneWidget);
    // var SubmitButton = find.byKey(Key("SubmitLogin"));
    // await tester.tap(SubmitButton);
    await tester.pumpAndSettle();

    var SubmitButton = find.byKey(Key("SubmitLogin"));
    await tester.tap(SubmitButton);
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

  testWidgets('Navigation should work correctly', (WidgetTester tester) async {
    // await _auth.signInWithEmailAndPassword(
    //     email: "hamza@hotmail.com", password: "hamza123");

    await tester.pumpWidget(GetMaterialApp(
      home: MyDrawer(uid: "qf3ZAicM1ldmHPauNXYGA6ncvYl2"),
    ));

    expect(find.byType(Card), findsNWidgets(5));

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('My Plans'), findsOneWidget);
    expect(find.text('My Friends'), findsOneWidget);
    expect(find.text('Friends Plans'), findsOneWidget);
    expect(find.text('Public Events'), findsOneWidget);

    // final secondTab = find.text("Approved").first;
    await tester.tap(find.byType(Card).first);
  });

  testWidgets('My Plans should work correctly', (WidgetTester tester) async {
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

  testWidgets('PlanDetailsDialog displays correctly',
      (WidgetTester tester) async {
    // Create a fake Firestore instance
    final fakeFirestore = FakeFirebaseFirestore();

    // Create a fake plan repository
    final planRepository = PlansRepository(firestore: fakeFirestore);
    final collectionReference = fakeFirestore.collection('plans');

    // Create a MyPlansBloc instance
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

    // Define the necessary data for the PlanDetailsDialog widget

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

    // Build the PlanDetailsDialog widget
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

    // Verify that the PlanDetailsDialog displays the correct data
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
