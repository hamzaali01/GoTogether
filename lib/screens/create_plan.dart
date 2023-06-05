import 'package:firebase_proj/screens/my_plans.dart';
import 'package:firebase_proj/common_widgets/widgets.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:firebase_proj/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:firebase_proj/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../repositories/plan_repository.dart';

class CreatePlan extends StatefulWidget {
  final String uid;
  final FirebaseFirestore firestore;
  const CreatePlan({super.key, required this.uid, required this.firestore});

  @override
  State<CreatePlan> createState() => _CreatePlanState();
}

class _CreatePlanState extends State<CreatePlan> {
  String? errorMessage = '';
  bool? isPublic = false;
  DateTime _selectedDateTime = DateTime.now();

  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerLName = TextEditingController();

  List<String> _selectedFriends = [];

  LatLng mapLocation = LatLng(24.8607, 67.0011);

  final _formKey = GlobalKey<FormState>();

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : '$errorMessage',
      style: TextStyle(color: Colors.red),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          GlobalSnackbar.show(context, 'Creating Plan');
          String status =
              await PlansRepository(firestore: widget.firestore).createPlan(
            widget.uid,
            _controllerTitle.text,
            _controllerLocation.text,
            mapLocation,
            _controllerDescription.text,
            _selectedDateTime.toString(),
            isPublic.toString(),
            _selectedFriends,
          );
          if (status == "Success") {
            Get.to(MyPlans(
              uid: widget.uid,
              firestore: FirebaseFirestore.instance,
            ));
            GlobalSnackbar.show(context, 'Plan Created Successfully');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to Create Plan'),
                duration: Duration(seconds: 2), // Optional duration
              ),
            );
            setState(() {
              errorMessage = "Some error occurred when creating the plan";
            });
          }
        } else {
          setState(() {
            GlobalSnackbar.show(
                context, 'Please fill the required fields correctly');
            errorMessage = "Title and Location cannot be empty";
          });
        }
      },
      child: Text("Create"),
    );
  }

  void onMarkerPositionChanged(LatLng markerPosition) {
    setState(() {
      mapLocation = markerPosition;
    });
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 5),
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
                return 'Please enter the title';
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
                return 'Please enter the location';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ShowMap(
                    onMarkerPositionChanged: onMarkerPositionChanged,
                    initialPosition: mapLocation,
                    type: "Select",
                  );
                },
              );
            },
            child: Text("Select Location on Map"),
          ),
          SizedBox(height: 16),
          TextFormField(
            maxLines: 3,
            controller: _controllerDescription,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
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
                      _selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
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
              future: UserRepository(firestore: widget.firestore)
                  .getFriendsByUid(widget.uid),
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
                    items: friendItems,
                    searchable: true,
                    //  listType: MultiSelectListType.CHIP,
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
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              form(),
            ],
          ),
        ),
      ),
    );
  }
}
