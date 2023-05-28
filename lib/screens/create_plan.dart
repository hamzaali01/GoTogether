import 'package:firebase_proj/screens/my_plans.dart';
import 'package:firebase_proj/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:firebase_proj/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../repositories/plan_repository.dart';

class CreatePlan extends StatefulWidget {
  const CreatePlan({super.key});

  @override
  State<CreatePlan> createState() => _CreatePlanState();
}

class _CreatePlanState extends State<CreatePlan> {
  String? errorMessage = '';
  bool? isPublic = false;
  DateTime _selectedDateTime = DateTime.now();

  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();
  //final TextEditingController _controllerDateTime = TextEditingController();
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerLName = TextEditingController();

  List<String> _selectedFriends = [];

  LatLng mapLocation = new LatLng(24.8607, 67.0011);

  final _formKey = GlobalKey<FormState>();

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : '$errorMessage',
        style: TextStyle(color: Colors.red));
  }

  Widget _submitButton() {
    return ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            GlobalSnackbar.show(context, 'Creating Plan');
            String status = await PlansRepository().createPlan(
                Auth().currentUser!.uid,
                _controllerTitle.text,
                _controllerLocation.text,
                mapLocation,
                _controllerDescription.text,
                _selectedDateTime.toString(),
                isPublic.toString(),
                _selectedFriends);
            if (status == "Success") {
              Get.to(MyPlans(uid: Auth().currentUser!.uid));
              GlobalSnackbar.show(context, 'Plan Created Successfully');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to Create Plan'),
                  duration: Duration(seconds: 2), // Optional duration
                ),
              );
              setState(() {
                errorMessage = "Some error occured when creating Plan";
              });
            }
          } else {
            setState(() {
              GlobalSnackbar.show(
                  context, 'Please fill the required fields correctly');
              errorMessage = "Title and Location can not be empty";
            });
          }
        },
        child: Text("Create"));
  }

  void onMarkerPositionChanged(LatLng markerPosition) {
    // Use the marker position as needed
    // print(markerPosition);
    mapLocation = markerPosition;
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // _errorMessage(),
          SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: _controllerTitle,
            decoration: InputDecoration(
              labelText: 'Title',
              suffixIcon: Icon(
                Icons.star,
                color: Colors.red,
                size: 10,
              ),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the Title';
              }
              if (value.length > 35) {
                return 'Title should be less than 36 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _controllerLocation,
            decoration: InputDecoration(
              labelText: 'Location ',
              helperText: "(Please type the city name if the plan is Public)",
              helperStyle: TextStyle(fontWeight: FontWeight.bold),
              suffixIcon: Icon(
                Icons.star,
                color: Colors.red,
                size: 10,
              ),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter Location ';
              }
              return null;
            },
          ),
          SizedBox(
            height: 16,
          ),
          ElevatedButton(
              onPressed: () {
                // Get.to(MyMap());
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ShowMap(
                        onMarkerPositionChanged: onMarkerPositionChanged,
                        initialPosition: mapLocation,
                        type: "Select",
                      );
                    });
              },
              child: Text("Select Location on Map")),
          //Text("mapLocation: " + mapLocation.toString()),
          SizedBox(
            height: 16,
          ),
          TextFormField(
            maxLines: 3,
            controller: _controllerDescription,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            // validator: (value) {
            //   if (value!.isEmpty) {
            //     return 'Please enter some description';
            //   }
            //   return null;
            // },
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Select a date and time',
              border: OutlineInputBorder(),
            ),
            onTap: () {
              DatePicker.showDateTimePicker(
                context,
                showTitleActions: true,
                minTime: DateTime.now(),
                maxTime: DateTime(2050, 12, 31),
                onConfirm: (date) async {
                  TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(date),
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _selectedDateTime = DateTime(date.year, date.month,
                          date.day, selectedTime.hour, selectedTime.minute);
                    });
                  }
                },
                currentTime: _selectedDateTime,
                locale: LocaleType.en,
              );
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a date and time';
              }
              return null;
            },
            controller:
                TextEditingController(text: _selectedDateTime.toString()),
          ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            child: CheckboxListTile(
              activeColor: Colors.green,
              //   controlAffinity: ListTileControlAffinity.leading,
              title: Text('Public'),
              value: isPublic,
              onChanged: (bool? value) {
                setState(() {
                  isPublic = value;
                });
              },
            ),
          ),
          SizedBox(height: 16),
          if (!isPublic!)
            FutureBuilder<List<DocumentSnapshot>>(
              future: UserRepository().getFriendsByUid(Auth().currentUser!.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final friendDocs = snapshot.data;

                final friendItems = friendDocs!
                    .map((doc) => MultiSelectItem<String>(doc.id, doc['name']))
                    .toList();

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  child: MultiSelectDialogField<String>(
                    buttonIcon: Icon(Icons.person_add_alt),
                    // separateSelectedItems: true,
                    items: friendItems,
                    searchable: true,
                    title: Text("Select Friends"),
                    selectedItemsTextStyle: TextStyle(color: Colors.blue),
                    buttonText: Text("Select Friends"),
                    onConfirm: (List<String> selectedFriends) {
                      setState(() {
                        _selectedFriends = selectedFriends;
                      });
                    },
                  ),
                );
              },
            ),
          SizedBox(height: 16),
          _submitButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Plan"),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Padding(
              //   padding: const EdgeInsets.all(50.0),
              //   child: Text(
              //     isLogin ? 'LOGIN' : 'REGISTER',
              //     style: TextStyle(fontSize: 30),
              //   ),
              // ),
              // _errorMessage(),
              form(),
            ],
          ),
        ),
      ),
    );
  }
}




          // TextFormField(
          //   controller: _locationController,
          //   decoration: InputDecoration(
          //     labelText: 'Location',
          //   ),
          //   validator: (value) {
          //     if (value!.isEmpty) {
          //       return 'Please pick a location';
          //     }
          //     return null;
          //   },
          // ),
          // Expanded(
          //   child: GoogleMap(
          //     initialCameraPosition: CameraPosition(
          //       target: _initialLocation,
          //       zoom: 15,
          //     ),
          //     markers: _markers,
          //     onTap: _onMapTapped,
          //     onMapCreated: (controller) {
          //       _mapController = controller;
          //     },
          //   ),
          // ),
