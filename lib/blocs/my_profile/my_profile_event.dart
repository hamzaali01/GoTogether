part of 'my_profile_bloc.dart';

abstract class MyProfileEvent extends Equatable {
  const MyProfileEvent();

  @override
  List<Object> get props => [];
}

class GetMyProfileEvent extends MyProfileEvent {
  final String userId;

  const GetMyProfileEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class SelectPictureEvent extends MyProfileEvent {
  final String userId;

  const SelectPictureEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
