part of 'my_plans_bloc.dart';

abstract class MyPlansEvent extends Equatable {
  const MyPlansEvent();

  @override
  List<Object> get props => [];
}

class GetMyPlansEvent extends MyPlansEvent {
  final String userId;

  const GetMyPlansEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class DeletePlanEvent extends MyPlansEvent {
  final String userId;
  final String planId;

  const DeletePlanEvent(this.userId, this.planId);

  @override
  List<Object> get props => [userId, planId];
}
