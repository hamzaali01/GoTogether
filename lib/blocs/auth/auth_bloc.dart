import 'package:bloc/bloc.dart';
import 'package:email_validator/email_validator.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(UnAuthenticatedState('')) {
    on<SignInEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        if (!EmailValidator.validate(event.email)) {
          emit(UnAuthenticatedState("Not a Valid Email"));
        } else {
          await Auth().signInWithEmailAndPassword(
              email: event.email, password: event.password);

          emit(AuthenticatedState());
        }
      } on FirebaseAuthException catch (e) {
        emit(UnAuthenticatedState(
            "The password that you've entered is incorrect for this email "));
      }
    });
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        if (event.password == '') {
          emit(UnAuthenticatedState("Please enter your password"));
        } else if (event.name == '') {
          emit(UnAuthenticatedState("Please enter your Name"));
        } else if (!EmailValidator.validate(event.email)) {
          emit(UnAuthenticatedState("Please enter a valid email"));
        } else if (event.confirmPassword != event.password) {
          emit(UnAuthenticatedState("Passwords do not match"));
        } else {
          await Auth().createUserWithEmailAndPassword(
              email: event.email, password: event.password, name: event.name);
          emit(AuthenticatedState());
        }
      } on FirebaseAuthException catch (e) {
        emit(UnAuthenticatedState(
            "The password that you've entered is incorrect for this email "));
      }
    });
    on<SignOutEvent>((event, emit) async {
      emit(UnAuthenticatedState(''));
      await Auth().signOut();
    });
    on<UserChangedEvent>((event, emit) {
      if (event.user != null) {
        emit(AuthenticatedState());
      } else {
        emit(UnAuthenticatedState('Signed out'));
      }
    });
    on<GoogleSignInEvent>((event, emit) async {
      User? user;
      try {
        user = await Auth().signInWithGoogle();
        emit(AuthenticatedState());
      } catch (e) {
        emit(UnAuthenticatedState(e.toString()));
      }
    });
  }
}
