import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_proj/repositories/user_repository.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<User?> signInWithGoogle() async {
    // Trigger the Google authentication flow.
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    // Obtain the auth details from the Google sign in.
    final GoogleSignInAuthentication googleAuth =
        await googleSignInAccount!.authentication;

    // Create a new credential.
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with the credential.
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;

    if (userCredential.additionalUserInfo!.isNewUser) {
      print('New user signed up with Google');
      UserRepository(firestore: FirebaseFirestore.instance)
          .createUser(user: user, name: googleSignInAccount.displayName);
    } else {
      print('Existing user logged in with Google');
    }

    return user;
  }

  Future<void> createUserWithEmailAndPassword(
      {required String email,
      required String password,
      required String name}) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = userCredential.user;
    await UserRepository(firestore: FirebaseFirestore.instance)
        .createUser(user: user, name: name);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
