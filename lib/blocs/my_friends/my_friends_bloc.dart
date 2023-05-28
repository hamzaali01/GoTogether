import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_proj/repositories/user_repository.dart';

part 'my_friends_event.dart';
part 'my_friends_state.dart';

class MyFriendsBloc extends Bloc<MyFriendsEvent, MyFriendsState> {
  MyFriendsBloc() : super(MyFriendsInitial()) {
    on<GetMyFriendsEvent>((event, emit) async {
      emit(LoadingState());
      try {
        final friends = await UserRepository().getFriendsByUid(event.userId);
        emit(LoadedState(friends, ""));
      } catch (e) {
        emit(ErrorState(e.toString()));
      }
    });
    on<AddFriendEvent>((event, emit) async {
      emit(LoadingState());
      String status =
          await UserRepository().addFriend(event.username, event.userId);
      try {
        final friends = await UserRepository().getFriendsByUid(event.userId);
        emit(LoadedState(friends, status));
      } catch (e) {
        emit(ErrorState(e.toString()));
      }
    });
  }
}
