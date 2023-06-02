import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_proj/repositories/user_repository.dart';
import 'package:firebase_proj/screens/login_register_page.dart';
import 'package:firebase_proj/widgets/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/my_profile/my_profile_bloc.dart';

class MyProfile extends StatefulWidget {
  final String uid;
  final FirebaseFirestore firestore;
  MyProfile({super.key, required this.uid, required this.firestore});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final User? user = Auth().currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        if (user == null) {
          Get.offAll(LoginPage());
          // BlocProvider.of<AuthBloc>(context).add(SignOutEvent());
          // Get.offAll(LoginPage());
        } else {
          //
        }
      }
    });

    // _fetchImageUrl(); // call the method to fetch the imageUrl
  }

  @override
  void dispose() {
    // Cancel any active streams or subscriptions here

    super.dispose();
  }

  Future<void> signOut() async {
    BlocProvider.of<AuthBloc>(context).add(SignOutEvent());
    // await Auth().signOut();
    //Get.to(LoginPage());
  }

  Widget _signOutButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: const StadiumBorder(),
        ),
        onPressed: signOut,
        child: const Text(
          'Sign Out',
          style: TextStyle(fontSize: 15),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyProfileBloc(firestore: widget.firestore)
        ..add(GetMyProfileEvent(widget.uid)),
      child: Scaffold(
          appBar: AppBar(
            title: title("My Profile", [Colors.white, Colors.white]),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // Colors.blue.shade800,
                    Colors.blue.shade800,
                    Colors.blue.shade300,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            centerTitle: true,
          ),
          drawer: MyDrawer(
            uid: widget.uid,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 114, 180, 255),
                  Color.fromARGB(255, 255, 255, 255),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: BlocBuilder<MyProfileBloc, MyProfileState>(
              builder: (context, state) {
                if (state is LoadedState) {
                  final userData = state.userData;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                            radius: 80.0,
                            backgroundImage: userData['profilePictureUrl'] != ''
                                ? NetworkImage(userData['profilePictureUrl'])
                                : null,
                            child: userData['profilePictureUrl'] == ""
                                ? Icon(
                                    Icons.person,
                                    size: 80,
                                  )
                                : null),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          onPressed: () async {
                            BlocProvider.of<MyProfileBloc>(context)
                                .add(SelectPictureEvent(widget.uid));
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image),
                              SizedBox(
                                width: 7,
                              ),
                              Text('Select Image'),
                            ],
                          ),
                        ),
                        Text(
                          userData['name'],
                          style: TextStyle(fontSize: 30),
                        ),
                        Text(
                          "Your UserName is: " + userData['username'],
                          style: TextStyle(fontSize: 20),
                        ),
                        // Text("Your Username " + UserRepository().getUserById(user.uid)),
                        _signOutButton(),
                      ],
                    ),
                  );
                } else if (state is LoadingState) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ErrorState) {
                  return Text(state.errorMessage);
                } else {
                  return Text("Unknown state");
                }
              },
            ),
          )),
    );
  }
}
