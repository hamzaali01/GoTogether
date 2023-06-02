// ignore_for_file: use_build_context_synchronously

import 'package:firebase_proj/screens/create_plan.dart';
import 'package:firebase_proj/screens/plan_discussion.dart';
import 'package:firebase_proj/widgets/PlanDetails.dart';
import 'package:flutter/material.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../blocs/friends_plans/friends_plan_bloc.dart';
import '../repositories/user_repository.dart';
import '../widgets/widgets.dart';
import 'package:latlong2/latlong.dart';

class FriendsPlans extends StatefulWidget {
  final String uid;
  final FirebaseFirestore firestore;
  FriendsPlans({required this.uid, required this.firestore});

  @override
  State<FriendsPlans> createState() => _FriendsPlansState();
}

class _FriendsPlansState extends State<FriendsPlans>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TabBar get _tabBar => TabBar(
        controller: _tabController,
        tabs: const <Widget>[
          Tab(
              icon: Icon(
                Icons.pending_actions,
                color: Colors.amber,
              ),
              text: "Pending"),
          Tab(
              icon: Icon(
                Icons.check,
                color: Color.fromARGB(255, 53, 255, 60),
              ),
              text: "Approved"),
          Tab(
              icon: Icon(
                Icons.cancel,
                color: Colors.red,
              ),
              text: "Declined"),
        ],
        //indicatorColor: Colors.red,
        //unselectedLabelColor: Colors.white,
        //labelColor: Colors.greenAccent,
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FriendsPlanBloc(firestore: widget.firestore)
        ..add(GetFriendsPlansEvent(widget.uid, 'PendingPlans')),
      child: Scaffold(
          drawer: MyDrawer(uid: widget.uid),
          backgroundColor: Color.fromARGB(
              255, 255, 83, 83), //Color.fromARGB(255, 56, 12, 12),
          appBar: AppBar(
            title: title("Friends Plans", [Colors.white, Colors.white]),
            // backgroundColor: Colors.black,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // Colors.blue.shade800,
                    Color.fromARGB(255, 255, 100, 100),
                    Color.fromARGB(255, 255, 47, 0),

                    // Color.fromARGB(255, 171, 135, 255),
                    // Color(0xFF5F53B7),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: _tabBar.preferredSize,
              child: ColoredBox(color: Colors.black, child: _tabBar),
            ),
          ),
          body: TabBarView(controller: _tabController, children: [
            Plans(uid: widget.uid, type: "PendingPlans"),
            Plans(uid: widget.uid, type: "ApprovedPlans"),
            Plans(uid: widget.uid, type: "DeclinedPlans"),
          ])),
    );
  }
}

class Plans extends StatefulWidget {
  final String uid;
  final String type;
  const Plans({required this.uid, required this.type});

  @override
  State<Plans> createState() => _PlansState();
}

class _PlansState extends State<Plans> {
  @override
  void initState() {
    super.initState();
    final friendsPlanBloc = BlocProvider.of<FriendsPlanBloc>(context);
    friendsPlanBloc.add(GetFriendsPlansEvent(
      widget.uid,
      widget.type,
    ));
  }

  void onMarkerPositionChanged(LatLng markerPosition) {
    // print(markerPosition);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsPlanBloc, FriendsPlanState>(
      builder: (context, state) {
        if (state is LoadingState) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.white,
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
              String time12Hour =
                  DateFormat('hh:mm a').format(DateTime.parse(dateTimeString));
              String dayName = DateFormat('EEEE').format(dateTime);
              String monthName = DateFormat('MMMM').format(dateTime);

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
              final _color;
              if (widget.type == 'PendingPlans') {
                _color = Colors.lightBlue;
              } else if (widget.type == 'ApprovedPlans') {
                _color = Colors.indigo;
              } else if (widget.type == 'DeclinedPlans') {
                _color = Colors.teal;
              } else
                _color = Colors.pink;

              return Card(
                color: _color,
                elevation: 10,
                shadowColor: Colors.deepOrange,
                //shape: Border.all(color: Colors.black, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  // height: 150,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          // Colors.blue.shade800,
                          _color,
                          Color.fromARGB(255, 136, 1, 255),
                          // _color,
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20)),
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
                                color: Color.fromARGB(255, 255, 255, 255),
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
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        SizedBox(
                          height: 7,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.type != "ApprovedPlans")
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 35, 206, 41),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)))),
                                onPressed: () async {
                                  BlocProvider.of<FriendsPlanBloc>(context).add(
                                      UpdatePlanStatusEvent(widget.uid, planId,
                                          "ApprovedPlans", widget.type));
                                  GlobalSnackbar.show(context, "Updating");
                                },
                                child: Text('Approve'),
                              ),
                            SizedBox(width: 8.0),
                            if (widget.type != "DeclinedPlans")
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)))),
                                onPressed: () async {
                                  BlocProvider.of<FriendsPlanBloc>(context).add(
                                      UpdatePlanStatusEvent(widget.uid, planId,
                                          "DeclinedPlans", widget.type));
                                  GlobalSnackbar.show(context, "Updating");
                                },
                                child: Text('Decline'),
                              ),
                          ],
                        ),

                        // Row(
                        //   children: [
                        //     Text(Invited.toString()),
                        //     Text("Yo"),
                        //   ],
                        // )
                      ],
                    ),
                    onTap: () async {
                      UserRepository(firestore: FirebaseFirestore.instance)
                          .getUserById(creator)
                          .then((data) async {
                        dynamic creatorData = data.data();
                        List<DocumentSnapshot> friendDocs =
                            await UserRepository(
                                    firestore: FirebaseFirestore.instance)
                                .getFriendsByUid(creator);
                        final PendingIDs = plan?['Invited']['Pending'];
                        final ApprovedIDs = plan?['Invited']['Approved'];
                        final DeclinedIDs = plan?['Invited']['Declined'];

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
                              onMarkerPositionChanged: onMarkerPositionChanged,
                              initialPosition: markerPosition,
                              plans: plans,
                              index: index,
                              friendDocs: friendDocs,
                              uid: widget.uid,
                            );
                          },
                        );
                      });
                    },
                  ),
                ),
              );
            },
          );
        } else if (state is ErrorState) {
          return Text('Error: ${state.errorMessage}');
        } else {
          return Center(child: Text('Unknown state'));
        }
      },
    );
  }
}
