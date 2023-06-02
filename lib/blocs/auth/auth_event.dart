part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({required this.email, required this.password});

  @override
  List<Object> get props => [];
}

class GoogleSignInEvent extends AuthEvent {
  const GoogleSignInEvent();

  @override
  List<Object> get props => [];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String confirmPassword;

  const SignUpEvent(
      {required this.email,
      required this.password,
      required this.confirmPassword,
      required this.name});

  @override
  List<Object> get props => [];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();

  @override
  List<Object> get props => [];
}

class UserChangedEvent extends AuthEvent {
  final User? user;

  UserChangedEvent({required this.user});
}
