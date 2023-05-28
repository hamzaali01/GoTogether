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

  const LoadedState(this.plans);

  @override
  List<Object> get props => [plans];
}

class ErrorState extends MyPlansState {
  final String errorMessage;
  const ErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
