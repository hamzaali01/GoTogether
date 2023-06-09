// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_proj/blocs/my_plans/my_plans_bloc.dart';
import 'package:firebase_proj/repositories/user_repository.dart';
import 'package:firebase_proj/screens/create_plan.dart';
import 'package:firebase_proj/screens/plan_discussion.dart';
import 'package:firebase_proj/common_widgets/PlanDetails.dart';
import 'package:flutter/material.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../common_widgets/widgets.dart';

class MyPlans extends StatefulWidget {
  final String uid;
  final FirebaseFirestore firestore;
  MyPlans({required this.uid, required this.firestore});

  @override
  State<MyPlans> createState() => _MyPlansState();
}

class _MyPlansState extends State<MyPlans> {
  void onMarkerPositionChanged(LatLng markerPosition) {
    // print(markerPosition);
  }

  // final User? user = Auth().currentUser;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyPlansBloc(firestore: widget.firestore)
        ..add(GetMyPlansEvent(widget.uid)),
      child: Scaffold(
        drawer: MyDrawer(uid: widget.uid),
        appBar: AppBar(
          title: title("My Plans", [Colors.white, Colors.white]),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // Colors.blue.shade800,
                  Color.fromARGB(255, 255, 214, 6),
                  Color.fromARGB(255, 255, 130, 14),

                  // Color.fromARGB(255, 171, 135, 255),
                  // Color(0xFF5F53B7),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          // backgroundColor:
          //   const Color.fromARGB(255, 246, 100, 100), //Colors.blue,
          // backgroundColor: Colors.blue,
          elevation: 10,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 85, 47),
                Color.fromARGB(255, 255, 148, 54),
                Color.fromARGB(255, 255, 255, 255),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: BlocBuilder<MyPlansBloc, MyPlansState>(
            builder: (context, state) {
              if (state is LoadingState) {
                return Center(
                    child: CircularProgressIndicator(
                        //backgroundColor: Colors.blue,
                        ));
              } else if (state is LoadedState) {
                final plans = state.plans;
                //print(plans.length);

                if (state.status != "") {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    GlobalSnackbar.show(context, state.status);
                  });
                }

                if (plans.length == 0) {
                  return Center(
                      child: Text(
                    "You have no Plans here!",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ));
                }

                return ListView.builder(
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    // final plan = plans[index].data();
                    final plan = plans[index].data() as Map<String, dynamic>?;
                    final title = plan?['title'];
                    final description = plan?['description'];
                    // final Invited = plan?['Invited']['Approved'];
                    final Pending = plan?['Invited']['Pending'].length;
                    final Approved = plan?['Invited']['Approved'].length;
                    final Declined = plan?['Invited']['Declined'].length;
                    final Invited = Pending + Approved + Declined;
                    final creator = plan?['creator'];
                    final location = plan?['location'];
                    final dateTimeString = plan?['date'];
                    DateTime dateTime = DateTime.parse(dateTimeString);

                    String date = DateFormat('yyyy-MM-dd').format(dateTime);
                    String time = DateFormat('HH:mm').format(dateTime);
                    String time12Hour = DateFormat('hh:mm a')
                        .format(DateTime.parse(dateTimeString));
                    String dayName = DateFormat('EEEE').format(dateTime);
                    String monthName = DateFormat('MMMM').format(dateTime);

                    final bloc = BlocProvider.of<MyPlansBloc>(context);

                    final mapLocation;
                    if (plan?['mapLocation'] != null) {
                      mapLocation = plan?['mapLocation'] as GeoPoint;
                      // print(mapLocation.latitude);
                    } else {
                      mapLocation = GeoPoint(24.8607, 67.0011);
                    }
                    final markerPosition =
                        LatLng(mapLocation.latitude, mapLocation.longitude);

                    final planSnapshot = plans[index];
                    final planId = planSnapshot.id;
                    // final _color = Colors.lightBlue;

                    return Card(
                      //  color: _color,
                      elevation: 10,
                      shadowColor: const Color.fromARGB(255, 237, 34, 255),
                      //shape: Border.all(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(
                          // height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 255, 179, 0),
                                Color.fromARGB(255, 248, 27, 27),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: ListTile(
                            // tileColor: Colors.red,
                            textColor: Colors.white,
                            title: Text(
                              title ?? 'No title',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  time12Hour,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                                Text(
                                  dayName,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                ),
                                Text(
                                  monthName + " " + date,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //  Text(description ?? 'No description'),
                                SizedBox(
                                  height: 7,
                                ),
                                if (plan?['Public'].toString() == "true")
                                  Text(
                                    "Public Event \nPeople Going: " +
                                        Approved.toString(),
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontWeight: FontWeight.bold),
                                  ),

                                if (plan?['Public'].toString() == "false")
                                  Text("Invited: " + Invited.toString()),
                                if (plan?['Public'].toString() == "false")
                                  Text(
                                    "Approved: " + Approved.toString(),
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 53, 255, 60),
                                        fontWeight: FontWeight.bold),
                                  ),
                                if (plan?['Public'].toString() == "false")
                                  Text(
                                    "Declined: " + Declined.toString(),
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                SizedBox(
                                  height: 7,
                                ),
                              ],
                            ),
                            onTap: () async {
                              UserRepository(
                                      firestore: FirebaseFirestore.instance)
                                  .getUserById(creator)
                                  .then((data) async {
                                dynamic creatorData = data.data();
                                List<DocumentSnapshot> friendDocs =
                                    await UserRepository(
                                            firestore:
                                                FirebaseFirestore.instance)
                                        .getFriendsByUid(creator);
                                final PendingIDs = plan?['Invited']['Pending'];
                                final ApprovedIDs =
                                    plan?['Invited']['Approved'];
                                final DeclinedIDs =
                                    plan?['Invited']['Declined'];

                                List PendingNames = [];
                                List ApprovedNames = [];
                                List DeclinedNames = [];
                                for (DocumentSnapshot friendDoc in friendDocs) {
                                  if (PendingIDs.contains(friendDoc.id)) {
                                    String friendName = friendDoc['name'];
                                    PendingNames.add(friendName);
                                  }
                                  if (ApprovedIDs.contains(friendDoc.id)) {
                                    String friendName = friendDoc['name'];
                                    ApprovedNames.add(friendName);
                                  }
                                  if (DeclinedIDs.contains(friendDoc.id)) {
                                    String friendName = friendDoc['name'];
                                    DeclinedNames.add(friendName);
                                  }

                                  if (plan?['Public'].toString() == "true") {
                                    ApprovedNames = ApprovedIDs;
                                  }
                                }
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PlanDetailsDialog(
                                      title: title,
                                      creatorData: creatorData,
                                      dayName: dayName,
                                      time12Hour: time12Hour,
                                      date: date,
                                      description: description,
                                      PendingNames: PendingNames,
                                      ApprovedNames: ApprovedNames,
                                      DeclinedNames: DeclinedNames,
                                      onMarkerPositionChanged:
                                          onMarkerPositionChanged,
                                      initialPosition: markerPosition,
                                      plans: plans,
                                      index: index,
                                      friendDocs: friendDocs,
                                      uid: widget.uid,
                                      bloc: bloc,
                                    );
                                  },
                                );
                              });
                            },
                          )),
                    );
                  },
                );
              } else if (state is ErrorState) {
                return Text('Error: ${state.errorMessage}');
              } else {
                return Center(child: Text(''));
              }
            },
          ),
        ),
        floatingActionButton: SizedBox(
          width: 150,
          child: FloatingActionButton(
            backgroundColor: Color.fromARGB(255, 234, 36, 112),
            onPressed: () {
              Get.to(() => CreatePlan(
                    uid: widget.uid,
                    firestore: widget.firestore,
                  ));
              //PlansRepository().createPlan(widget.uid);
            },
            shape: StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.add),
                  Expanded(child: Text("CREATE PLAN")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
