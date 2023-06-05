part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();

  @override
  List<Object> get props => [];
}

class UnAuthenticatedState extends AuthState {
  final String error;
  const UnAuthenticatedState(this.error);

  @override
  List<Object> get props => [];
}

class AuthenticatedState extends AuthState {
  const AuthenticatedState();

  @override
  List<Object> get props => [];
}

class AuthErrorState extends AuthState {
  const AuthErrorState();

  @override
  List<Object> get props => [];
}
