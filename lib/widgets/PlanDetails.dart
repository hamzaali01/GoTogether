import 'package:firebase_proj/blocs/my_plans/my_plans_bloc.dart';
import 'package:firebase_proj/repositories/plan_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../auth.dart';
import '../screens/plan_discussion.dart';
import 'widgets.dart';

class PlanDetailsDialog extends StatelessWidget {
  final GlobalKey<State> _dialogKey = GlobalKey<State>();
  final MyPlansBloc? bloc;

  final String title;
  final dynamic creatorData;
  final String dayName;
  final String time12Hour;
  final String date;
  final String description;
  final List PendingNames;
  final List ApprovedNames;
  final List DeclinedNames;
  final Function onMarkerPositionChanged;
  final LatLng initialPosition;
  final dynamic plans;
  final dynamic index;
  final dynamic friendDocs;
  final String uid;

  PlanDetailsDialog(
      {required this.title,
      required this.creatorData,
      required this.dayName,
      required this.time12Hour,
      required this.date,
      required this.description,
      required this.PendingNames,
      required this.ApprovedNames,
      required this.DeclinedNames,
      required this.onMarkerPositionChanged,
      required this.initialPosition,
      required this.plans,
      required this.index,
      required this.friendDocs,
      required this.uid,
      this.bloc});

  @override
  Widget build(BuildContext context) {
    dynamic planId = plans[index].id;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "Plan made by: ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: creatorData!["profilePictureUrl"] != ""
                        ? NetworkImage(creatorData!["profilePictureUrl"])
                        : null,
                    child: creatorData!["profilePictureUrl"] == ""
                        ? Icon(Icons.person)
                        : null,
                  ),
                  SizedBox(width: 10),
                  Text(
                    creatorData!["name"],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text("Plan Date: " + dayName + " " + time12Hour + " - " + date),
              Text("Plan Location: " +
                  plans[index].data()['location'].toString()),
              SizedBox(height: 20),
              Container(
                width: 400,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Details:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      description == "" ? "No details" : description,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ShowMap(
                          onMarkerPositionChanged: onMarkerPositionChanged,
                          initialPosition: initialPosition,
                          type: "ViewOnly",
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined),
                      SizedBox(
                        width: 5,
                      ),
                      Text("View Location in Map"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(PlanDiscussion(
                      planId: plans[index].id,
                      name: creatorData!["name"],
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat),
                      SizedBox(
                        width: 5,
                      ),
                      Text("View Discussion"),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              if (uid == plans[index].data()['creator'] && bloc != null)
                Center(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 202, 30, 30)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              key: _dialogKey,
                              title: Text('Delete Confirmation'),
                              content: Text(
                                  'Are you sure you want to delete this Plan?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Delete'),
                                  onPressed: () async {
                                    bloc!.add(DeletePlanEvent(uid, planId));
                                    // GlobalSnackbar.show(
                                    //     context, "Deleted Plan");
                                    Navigator.of(_dialogKey.currentContext!)
                                        .pop();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 10),
                          Text("Delete Plan"),
                        ],
                      )),
                ),
              SizedBox(
                height: 10,
              ),
              if (plans[index].data()['Public'].toString() == "true")
                Center(
                  child: Text(
                    ApprovedNames.length.toString() + " People Going",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 59, 59, 59)),
                  ),
                ),
              if (plans[index].data()['Public'].toString() == "false")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Pending",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 155, 33)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          height: ((friendDocs.length + 1) * 50).toDouble(),
                          width: 100.0,
                          child: ListView.builder(
                            // shrinkWrap: true,
                            itemCount: PendingNames.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  (index + 1).toString() +
                                      ": " +
                                      PendingNames[index],
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                        //
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Approved",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 53, 255, 60)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          height: ((friendDocs.length + 1) * 50).toDouble(),
                          width: 100.0,
                          child: ListView.builder(
                            // shrinkWrap: true,
                            itemCount: ApprovedNames.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  (index + 1).toString() +
                                      ": " +
                                      ApprovedNames[index],
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Declined",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          height: ((friendDocs.length + 1) * 50).toDouble(),
                          width: 100.0,
                          child: ListView.builder(
                            //shrinkWrap: true,
                            itemCount: DeclinedNames.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  (index + 1).toString() +
                                      ": " +
                                      DeclinedNames[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
