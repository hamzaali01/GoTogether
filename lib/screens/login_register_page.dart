import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_proj/screens/my_plans.dart';
import 'package:firebase_proj/screens/my_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../blocs/auth/auth_bloc.dart';
import '../common_widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();
  final TextEditingController _controllerName = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void signInWithEmailAndPassword() {
    BlocProvider.of<AuthBloc>(context).add(SignInEvent(
      email: _controllerEmail.text,
      password: _controllerPassword.text,
    ));
  }

  void createUserWithEmailAndPassword() {
    BlocProvider.of<AuthBloc>(context).add(SignUpEvent(
      email: _controllerEmail.text,
      password: _controllerPassword.text,
      confirmPassword: _controllerConfirmPassword.text,
      name: _controllerName.text,
    ));
  }

  Widget _entryField(String title, TextEditingController controller, Key key,
      {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        key: key,
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        obscureText: isPassword,
      ),
    );
  }

  Widget _errorMessage(String text) {
    if (text.isNotEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            text,
            style: TextStyle(
                color: const Color.fromARGB(255, 255, 17, 0),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _submitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFff9966), Color(0xFFff5e62)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: MaterialButton(
        onPressed: isLogin
            ? signInWithEmailAndPassword
            : createUserWithEmailAndPassword,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          isLogin ? 'Login' : 'Register',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 171, 135, 255),
              Color(0xFF5F53B7),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            isLogin ? "Register instead" : "Login instead",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _signInWithGoogle() {
    return ElevatedButton(
      onPressed: () {
        BlocProvider.of<AuthBloc>(context).add(GoogleSignInEvent());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/google_logo3.png',
            height: 25,
            width: 25,
          ),
          SizedBox(width: 8),
          Text(
            'Sign In With Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title("GoTogether", [
          Color.fromARGB(255, 255, 255, 255),
          Color.fromARGB(255, 255, 255, 255)
        ]),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade300,
                Colors.blue.shade800,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 10,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            //  WidgetsBinding.instance!.addPostFrameCallback((_) {
            Get.to(
              MyPlans(
                uid: Auth().currentUser!.uid,
                firestore: FirebaseFirestore.instance,
              ),
            );
            // });
          }
        },
        builder: (context, state) {
          if (state is UnAuthenticatedState) {
            return Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade300,
                          Colors.blue.shade800,
                          const Color.fromARGB(255, 246, 100, 100)
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Center(
                              child: Text(
                                isLogin ? 'LOGIN' : 'REGISTER',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 255, 255, 255),
                                        Color.fromARGB(255, 255, 255, 255)
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(
                                        Rect.fromLTWH(0, 0, 200, 70)),
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.7),
                                      offset: Offset(0, 3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _errorMessage(state.error),
                          _entryField(
                            'Email',
                            _controllerEmail,
                            Key("EnterEmail"),
                          ),
                          _entryField(
                            'Password',
                            _controllerPassword,
                            Key("EnterPassword"),
                            isPassword: true,
                          ),
                          if (!isLogin)
                            Column(
                              children: [
                                _entryField(
                                  'Confirm Password',
                                  _controllerConfirmPassword,
                                  Key("EnterConfirmPassword"),
                                  isPassword: true,
                                ),
                                _entryField(
                                  'Name',
                                  _controllerName,
                                  Key("EnterName"),
                                ),
                              ],
                            ),
                          _submitButton(),
                          SizedBox(
                            height: 10,
                          ),
                          _loginOrRegisterButton(),
                          SizedBox(
                            height: 10,
                          ),
                          _signInWithGoogle(),
                          SizedBox(height: 10),
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/GoTogether.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is AuthLoadingState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Text("");
          }
        },
      ),
    );
  }
}
