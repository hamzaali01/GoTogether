part of 'my_friends_bloc.dart';

abstract class MyFriendsState extends Equatable {
  const MyFriendsState();

  @override
  List<Object> get props => [];
}

class MyFriendsInitial extends MyFriendsState {}

class LoadingState extends MyFriendsState {
  const LoadingState();

  @override
  List<Object> get props => [];
}

class LoadedState extends MyFriendsState {
  final List<dynamic> friends;
  final String status;

  const LoadedState(this.friends, this.status);

  @override
  List<Object> get props => [friends, status];
}

class ErrorState extends MyFriendsState {
  final String errorMessage;
  const ErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
