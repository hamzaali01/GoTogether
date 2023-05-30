import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_proj/blocs/friends_plans/friends_plan_bloc.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:firebase_proj/screens/login_register_page.dart';
import 'package:firebase_proj/screens/my_plans.dart';
import 'package:firebase_proj/screens/my_profile.dart';
import 'package:firebase_proj/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_proj/screens/friends_plans.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import '../mock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class MockFirebaseAuth extends Mock implements Auth {}

// class MockFirebaseUser extends Mock implements User {}

class MockPlanRepository extends Mock implements PlansRepository {}

class MockFriendsPlanBloc extends Mock implements FriendsPlanBloc {}

Future<void> main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });
  // final mockPlanRepository = MockPlanRepository();
  MockFirebaseAuth _auth = MockFirebaseAuth();

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
    // await _auth.signInWithEmailAndPassword(
    //     email: "hamza@hotmail.com", password: "hamza123");

    await tester.pumpWidget(GetMaterialApp(
      home: FriendsPlans(uid: "qf3ZAicM1ldmHPauNXYGA6ncvYl2"),
    ));

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byType(Plans), findsOneWidget);
    //expect(find.byType(Plans), findsNWidgets(3));

    expect(find.text("Pending"), findsOneWidget);
    expect(find.text("Approved"), findsOneWidget);
    expect(find.text("Declined"), findsOneWidget);

    await tester.pump();

    //expect(find.text("You have no Plans here!"), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // expect(find.text("New Footy Plan"), findsNothing);

    // final tabbar = tester.widget(find.byType(TabBar)) as TabBar;
    // await tester.pump();

    // final secondTab = find.text("Approved").first;
    // await tester.tap(secondTab);
    // await tester.pump();

    //expect(find.byType(CircularProgressIndicator), findsOneWidget);

    //expect(find.text("New Footy Plan"), findsOneWidget);
    //final button = find.byType(ElevatedButton);
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
}
