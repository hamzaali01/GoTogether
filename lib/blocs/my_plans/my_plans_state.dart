part of 'my_plans_bloc.dart';

abstract class MyPlansState extends Equatable {
  const MyPlansState();

  @override
  List<Object> get props => [];
}

class MyPlanBlocInitial extends MyPlansState {}

class LoadingState extends MyPlansState {
  const LoadingState();

  @override
  List<Object> get props => [];
}

class LoadedState extends MyPlansState {
  final List<dynamic> plans;
  final String status;

  const LoadedState(this.plans, this.status);

  @override
  List<Object> get props => [plans, status];
}

class ErrorState extends MyPlansState {
  final String errorMessage;
  const ErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
