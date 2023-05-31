import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/plan_repository.dart';

part 'friends_plan_event.dart';
part 'friends_plan_state.dart';

class FriendsPlanBloc extends Bloc<FriendsPlanEvent, FriendsPlanState> {
  FirebaseFirestore firestore;

  //FriendsPlanBloc(this.firestore);

  FriendsPlanBloc({required this.firestore}) : super(FriendsPlanBlocInitial()) {
    on<GetFriendsPlansEvent>((event, emit) async {
      emit(LoadingState());
      try {
        final plans = await PlansRepository(firestore: firestore)
            .getFriendsPlans(event.userId, event.tabType);
        emit(LoadedState(plans, ""));
      } catch (e) {
        emit(ErrorState('Failed to fetch friends\' plans: $e'));
      }
    });
    on<UpdatePlanStatusEvent>((event, emit) async {
      emit(LoadingState());
      String status = await PlansRepository(firestore: firestore)
          .updatePlanStatus(event.userId, event.planId, event.changeTo);
      try {
        final plans = await PlansRepository(firestore: firestore)
            .getFriendsPlans(event.userId, event.tabType);

        emit(LoadedState(plans, status));
      } catch (e) {
        emit(ErrorState('Failed to fetch friends\' plans: $e'));
      }
    });
  }
}
