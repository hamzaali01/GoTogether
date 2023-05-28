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
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MyProfile extends StatefulWidget {
  MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final User? user = Auth().currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // User is signed out, switch to login screen
        Get.offAll(LoginPage());
      } else {}
    });

    _fetchImageUrl(); // call the method to fetch the imageUrl
  }

  Future<void> signOut() async {
    await Auth().signOut();
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

  Future<void> _fetchImageUrl() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final doc = await ref.get();
    if (doc.exists) {
      setState(() {
        _imageUrl = doc.get('profilePictureUrl');
      });
    }
  }

  // @override
  // void initState() {
  //   super.initState();

  // }

  File? _imageFile;
  bool _isLoading = false;
  String? _imageUrl;

  Future<void> _selectImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile!.path);
    });

    final userId = Auth().currentUser!.uid;
    await _uploadImage(userId);
  }

  Future<void> _uploadImage(String userId) async {
    if (_imageFile == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final fileName = 'profile_picture.jpg';
    final destination = 'users/$userId/$fileName';

    final storageRef = FirebaseStorage.instance.ref(destination);
    final uploadTask = storageRef.putFile(_imageFile!);
    final snapshot = await uploadTask.whenComplete(() {});
    final url = await snapshot.ref.getDownloadURL();
    setState(() {
      _imageUrl = url; // save the image URL to the _imageUrl variable
    });

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update({'profilePictureUrl': _imageUrl});

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
      ),
      drawer: MyDrawer(),
      body: FutureBuilder(
        future: UserRepository().getUserById(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return Text('No profile found.');
          } else {
            final userData = snapshot.data!;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                      radius: 80.0,
                      backgroundImage: NetworkImage(_imageUrl!),
                      child: _imageUrl == ""
                          ? Icon(
                              Icons.person,
                              size: 80,
                            )
                          : null),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _selectImage,
                          child: Text('Select Image'),
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
          }
        },
      ),
    );
  }
}
