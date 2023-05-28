part of 'friends_plan_bloc.dart';

abstract class FriendsPlanState extends Equatable {
  const FriendsPlanState();

  @override
  List<Object> get props => [];
}

class FriendsPlanBlocInitial extends FriendsPlanState {}

class LoadingState extends FriendsPlanState {
  const LoadingState();

  @override
  List<Object> get props => [];
}

class LoadedState extends FriendsPlanState {
  final List<dynamic> plans;
  final String status;

  const LoadedState(this.plans, this.status);

  @override
  List<Object> get props => [plans, status];
}

class ErrorState extends FriendsPlanState {
  final String errorMessage;
  const ErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

//LoadingState
//LoadedState
//ErrorState
