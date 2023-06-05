part of 'friends_plan_bloc.dart';

abstract class FriendsPlanEvent extends Equatable {
  const FriendsPlanEvent();

  @override
  List<Object> get props => [];
}

class GetFriendsPlansEvent extends FriendsPlanEvent {
  final String userId;
  final String tabType; // Can be 'pending', 'approved', or 'declined'

  const GetFriendsPlansEvent(this.userId, this.tabType); //

  @override
  List<Object> get props => [userId, tabType];
}

class UpdatePlanStatusEvent extends FriendsPlanEvent {
  final String userId;
  final String planId;
  final String changeTo;
  final String tabType;

  const UpdatePlanStatusEvent(
      this.userId, this.planId, this.changeTo, this.tabType);

  @override
  List<Object> get props => [userId, planId, changeTo, tabType];
}
//GetFriendsPlan Event
//UpdatePlanStatus Event
