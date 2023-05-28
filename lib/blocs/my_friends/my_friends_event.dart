part of 'my_friends_bloc.dart';

abstract class MyFriendsEvent extends Equatable {
  const MyFriendsEvent();

  @override
  List<Object> get props => [];
}

class GetMyFriendsEvent extends MyFriendsEvent {
  final String userId;

  const GetMyFriendsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddFriendEvent extends MyFriendsEvent {
  final String username;
  final String userId;

  const AddFriendEvent(this.username, this.userId);

  @override
  List<Object> get props => [username, userId];
}
