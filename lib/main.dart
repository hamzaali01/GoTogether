import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:firebase_proj/screens/friends_plans.dart';
import 'package:firebase_proj/screens/login_register_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'auth.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/friends_plans/friends_plan_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: GetMaterialApp(
          title: 'App Dev Project',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const LoginPage()),
    );
  }

  //  MultiBlocProvider(
  //       providers: [
  //         BlocProvider<FriendsPlanBloc>(
  //           create: (context) => FriendsPlanBloc(),
  //         ),
  //       ],
  //       child: const LoginPage(), //const Wrapper(),
  //     ),
}
