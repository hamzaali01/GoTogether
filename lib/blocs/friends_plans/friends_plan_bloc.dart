import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/plan_repository.dart';

part 'friends_plan_event.dart';
part 'friends_plan_state.dart';

class FriendsPlanBloc extends Bloc<FriendsPlanEvent, FriendsPlanState> {
  FriendsPlanBloc() : super(FriendsPlanBlocInitial()) {
    on<GetFriendsPlansEvent>((event, emit) async {
      emit(LoadingState());
      try {
        final plans = await PlansRepository()
            .getFriendsPlans(event.userId, event.tabType);
        emit(LoadedState(plans, ""));
      } catch (e) {
        emit(ErrorState('Failed to fetch friends\' plans: $e'));
      }
    });
    on<UpdatePlanStatusEvent>((event, emit) async {
      emit(LoadingState());
      String status = await PlansRepository()
          .updatePlanStatus(event.userId, event.planId, event.changeTo);
      try {
        final plans = await PlansRepository()
            .getFriendsPlans(event.userId, event.tabType);

        emit(LoadedState(plans, status));
      } catch (e) {
        emit(ErrorState('Failed to fetch friends\' plans: $e'));
      }
    });
  }
}
