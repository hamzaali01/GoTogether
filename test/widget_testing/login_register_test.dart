import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj/blocs/auth/auth_bloc.dart';
import 'package:firebase_proj/screens/login_register_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../mock.dart';

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
      home: BlocProvider(
        create: (context) => AuthBloc(),
        child: LoginPage(),
      ),
    ));

    expect(find.text('LOGIN'), findsOneWidget);
    var textFieldEmail = find.byKey(Key("EnterEmail"));
    await tester.enterText(textFieldEmail, "hamza@hotmail.com");
    var textFieldPassword = find.byKey(Key("EnterPassword"));
    await tester.enterText(textFieldPassword, "hamza123");

    //var RegisterInsteadButton = find.text("Register instead");
    var RegisterInsteadButton = find.textContaining("Register instead");
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

    var SubmitButton = find.text("Register");
    await tester.tap(SubmitButton);
  });
}
