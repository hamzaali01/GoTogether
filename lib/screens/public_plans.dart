// ignore_for_file: use_build_context_synchronously

import 'package:firebase_proj/screens/create_plan.dart';
import 'package:firebase_proj/screens/plan_discussion.dart';
import 'package:firebase_proj/widgets/PlanDetails.dart';
import 'package:flutter/material.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../repositories/user_repository.dart';
import '../widgets/widgets.dart';

class PublicPlans extends StatefulWidget {
  final String uid;
  final FirebaseFirestore firestore;

  PublicPlans({required this.uid, required this.firestore});

  @override
  State<PublicPlans> createState() => _PublicPlansState();
}

class _PublicPlansState extends State<PublicPlans> {
  bool _isSearching = false;
  List<DocumentSnapshot>? allPlans;
  List<DocumentSnapshot>? displayedPlans;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    final plans =
        await PlansRepository(firestore: widget.firestore).getPublicPlans();
    setState(() {
      allPlans = plans;
      displayedPlans = plans;
    });
  }

  void filterPlans(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedPlans = allPlans;
      } else {
        displayedPlans = allPlans?.where((plan) {
          final location = plan['location'] as String;
          return location.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void onMarkerPositionChanged(LatLng markerPosition) {
    // print(markerPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(uid: widget.uid),
      backgroundColor: Color.fromARGB(255, 58, 23, 163),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: _isSearching
              ? _buildSearchField()
              : title("Public Plans", [Colors.white, Colors.white]),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // Colors.blue.shade800,
                  Color.fromARGB(255, 106, 21, 180),
                  Color.fromARGB(255, 117, 35, 249),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          actions: _buildActions(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchPlans();
        },
        child: _buildPlanList(),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: filterPlans,
      decoration: InputDecoration(
        hintText: "Search by location...",
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _isSearching = false;
              displayedPlans = allPlans;
            });
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ];
    }
  }

  Widget _buildPlanList() {
    if (displayedPlans == null) {
      return Center(child: CircularProgressIndicator());
    } else if (displayedPlans!.isEmpty) {
      return Center(
        child: Text(
          "No Public Plans Found!",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: displayedPlans!.length,
        itemBuilder: (context, index) {
          // final plan = plans[index].data();
          final plan = displayedPlans![index].data() as Map<String, dynamic>?;
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

          final planSnapshot = displayedPlans![index];
          final planId = planSnapshot.id;
          final _color = Colors.pinkAccent;

          return Card(
            color: _color,
            elevation: 10,
            shadowColor: Colors.black,
            //shape: Border.all(color: Colors.black, width: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      Color.fromARGB(255, 86, 14, 255),
                      Color.fromARGB(255, 255, 6, 72),
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
                      Text(
                        "People Going: " + Approved.toString(),
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 35, 206, 41)),
                          onPressed: () async {
                            GlobalSnackbar.show(context, "Updating Going");
                            await PlansRepository(firestore: widget.firestore)
                                .updatePlanStatus(
                                    widget.uid, planId, "ApprovedPlans");

                            fetchPlans();
                            GlobalSnackbar.show(context, "Updated");

                            // setState(() {
                            //   // displayedPlans![index] = planSnapshot;
                            // });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Text('Going'),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 206, 35, 35)),
                          onPressed: () async {
                            GlobalSnackbar.show(context, "Updating Going");
                            await PlansRepository(firestore: widget.firestore)
                                .updatePlanStatus(widget.uid, planId, "");
                            fetchPlans();
                            GlobalSnackbar.show(context, "Updated");
                            // setState(() {
                            //   //  displayedPlans![index] = updatedPlanSnapshot;
                            // });
                          },
                          child: Text('Not Going'),
                        ),
                      ]),
                    ],
                  ),
                  onTap: () async {
                    //print("Opening Plan " + plans[index].data().toString());
                    UserRepository(firestore: widget.firestore)
                        .getUserById(creator)
                        .then((data) async {
                      dynamic creatorData = data.data();
                      List<DocumentSnapshot> friendDocs =
                          await UserRepository(firestore: widget.firestore)
                              .getFriendsByUid(creator);
                      final PendingIDs = plan?['Invited']['Pending'];
                      final ApprovedIDs = plan?['Invited']['Approved'];
                      final DeclinedIDs = plan?['Invited']['Declined'];

                      List PendingNames = [];
                      List ApprovedNames = ApprovedIDs;
                      List DeclinedNames = [];

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
                            plans: displayedPlans,
                            index: index,
                            friendDocs: friendDocs,
                            uid: widget.uid,
                          );
                        },
                      );
                    });
                  },
                )),
          );
        },
      );
    }
  }
}
