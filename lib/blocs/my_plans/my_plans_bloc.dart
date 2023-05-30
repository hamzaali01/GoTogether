import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/plan_repository.dart';

part 'my_plans_event.dart';
part 'my_plans_state.dart';

class MyPlansBloc extends Bloc<MyPlansEvent, MyPlansState> {
  MyPlansBloc() : super(MyPlanBlocInitial()) {
    on<GetMyPlansEvent>((event, emit) async {
      emit(LoadingState());
      try {
        final plans =
            await PlansRepository(firestore: FirebaseFirestore.instance)
                .getPlansByUid(event.userId);
        emit(LoadedState(plans, ""));
      } catch (e) {
        emit(ErrorState('Failed to fetch friends\' plans: $e'));
      }
    });
    on<DeletePlanEvent>((event, emit) async {
      emit(LoadingState());

      // try {
      String status =
          await PlansRepository(firestore: FirebaseFirestore.instance)
              .deletePlanAndRemoveFromUsers(event.planId);
      try {
        final plans =
            await PlansRepository(firestore: FirebaseFirestore.instance)
                .getPlansByUid(event.userId);
        emit(LoadedState(plans, status));
      } catch (e) {
        // emit(LoadedState([], e.toString()));
        emit(ErrorState('Failed to fetch friends\' plans: $e'));
      }

      // } catch (e) {
      //   emit(ErrorState('Failed to fetch delete\' plans: $e'));
      // }
    });
  }
}
