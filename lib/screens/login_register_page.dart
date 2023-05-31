import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_proj/screens/my_plans.dart';
import 'package:firebase_proj/screens/my_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerconfirmPassword =
      TextEditingController();
  final TextEditingController _controllerName = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        print("user signed innnnnnn");
        Get.to(MyPlans(
          uid: Auth().currentUser!.uid,
          firestore: FirebaseFirestore.instance,
        ));
      }
    });
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      if (_controllerconfirmPassword.text == '') {
        setState(() {
          errorMessage = "Please confirm your password";
        });
        return;
      }
      if (_controllerName.text == '') {
        setState(() {
          errorMessage = "Please enter your Name";
        });
        return;
      }
      if (!EmailValidator.validate(_controllerEmail.text)) {
        setState(() {
          errorMessage = "Please enter a valid email";
        });
        return;
      }
      if (_controllerconfirmPassword.text != _controllerPassword.text) {
        setState(() {
          errorMessage = "Passwords do not match";
        });
        return;
      }
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
          name: _controllerName.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _entryField(String title, TextEditingController controller, Key key) {
    return TextField(
      key: key,
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
      obscureText: title.toLowerCase() == 'password' ||
              title.toLowerCase() == 'confirm password'
          ? true
          : false,
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
        key: Key("SubmitLogin"),
        onPressed: isLogin
            ? signInWithEmailAndPassword
            : createUserWithEmailAndPassword,
        child: Text(isLogin ? 'Login' : 'Register'));
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Text(isLogin ? "Register instead" : "Login instead"));
  }

  Widget _signInWithGoogle() {
    return ElevatedButton(
        onPressed: Auth().signInWithGoogle, child: Text('Sign In With Google'));
  }

  // Widget form() {
  //   String _password = '';
  //   String _confirmPassword;

  //   return Form(
  //     child: Column(
  //       children: [
  //         TextFormField(
  //           obscureText: true,
  //           onChanged: (value) {
  //             _password = value;
  //           },
  //           decoration: InputDecoration(
  //             hintText: 'Enter password',
  //           ),
  //         ),
  //         TextFormField(
  //           obscureText: true,
  //           onChanged: (value) {
  //             _confirmPassword = value;
  //           },
  //           decoration: InputDecoration(
  //             hintText: 'Confirm password',
  //           ),
  //           validator: (value) {
  //             if (value!.isEmpty) {
  //               return 'Please confirm your password';
  //             }
  //             if (value != _password) {
  //               return 'Passwords do not match';
  //             }
  //             return null;
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Text(
                  isLogin ? 'LOGIN' : 'REGISTER',
                  style: TextStyle(fontSize: 30),
                ),
              ),
              _entryField('Email', _controllerEmail, Key("EnterEmail")),
              _entryField(
                  'Password', _controllerPassword, Key("EnterPassword")),
              if (!isLogin)
                Column(children: [
                  _entryField('Confirm Password', _controllerconfirmPassword,
                      Key("EnterConfirmPassword")),
                  _entryField('Name', _controllerName, Key("EnterName"))
                ]),
              _errorMessage(),
              _submitButton(),
              _loginOrRegisterButton(),
              _signInWithGoogle(),
              //form(),
            ],
          ),
        ),
      ),
    );
  }
}
