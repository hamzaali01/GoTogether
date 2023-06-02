part of 'my_profile_bloc.dart';

abstract class MyProfileState extends Equatable {
  const MyProfileState();

  @override
  List<Object> get props => [];
}

class MyProfileInitial extends MyProfileState {}

class LoadingState extends MyProfileState {
  const LoadingState();

  @override
  List<Object> get props => [];
}

class LoadedState extends MyProfileState {
  final userData;

  const LoadedState(this.userData);

  @override
  List<Object> get props => [userData];
}

class ErrorState extends MyProfileState {
  final String errorMessage;
  const ErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
