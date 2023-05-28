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

  const LoadedState(this.plans);

  @override
  List<Object> get props => [plans];
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
