import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_proj/screens/friends_plans.dart';
import 'package:firebase_proj/screens/my_profile.dart';
import 'package:firebase_proj/screens/my_friends.dart';
import 'package:firebase_proj/screens/my_plans.dart';
import 'package:firebase_proj/screens/public_plans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/friends_plans/friends_plan_bloc.dart';

class MyDrawer extends StatelessWidget {
  final uid;
  MyDrawer({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      key: Key("MyDrawer"),
      width: 240,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 150,
            child: const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'GoTogether',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ),
          Card(
            color: Colors.blue,
            child: ListTile(
              title: Text(
                'My Profile',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              onTap: () {
                Get.to(MyProfile(uid: uid));
                //Navigator.pop(context);
                // Handle item 1 tap
              },
            ),
          ),
          Card(
            color: Colors.amber,
            child: ListTile(
              title: Text('My Plans',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              onTap: () {
                Get.to(MyPlans(
                  uid: Auth().currentUser!.uid,
                  firestore: FirebaseFirestore.instance,
                ));
                //Navigator.pop(context);
              },
            ),
          ),
          Card(
            color: Colors.red,
            child: ListTile(
              title: Text('Friends Plans',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              onTap: () {
                // context.read<FriendsPlanBloc>().add(
                //     GetFriendsPlansEvent(Auth().currentUser!.uid, 'Pending'));
                Get.to(FriendsPlans(
                  uid: Auth().currentUser!.uid,
                  firestore: FirebaseFirestore.instance,
                ));
                //Navigator.pop(context);
              },
            ),
          ),
          Card(
            color: Color.fromARGB(255, 24, 204, 30),
            child: ListTile(
              title: Text('My Friends',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              onTap: () {
                Get.to(MyFriends(
                  uid: Auth().currentUser!.uid,
                  firestore: FirebaseFirestore.instance,
                ));
                //Navigator.pop(context);
              },
            ),
          ),
          Card(
            color: Colors.deepPurple,
            child: ListTile(
              title: Text('Public Events',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              onTap: () {
                Get.to(PublicPlans(
                  uid: Auth().currentUser!.uid,
                  firestore: FirebaseFirestore.instance,
                ));
                //Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShowMap extends StatefulWidget {
  final onMarkerPositionChanged;
  final initialPosition;
  final type;
  const ShowMap(
      {super.key,
      required this.onMarkerPositionChanged,
      required this.initialPosition,
      required this.type});

  @override
  State<ShowMap> createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          width: 1500,
          height: 1500,
          child: MyMap(
            onMarkerPositionChanged: widget.onMarkerPositionChanged,
            initialPosition: widget.initialPosition,
            type: widget.type,
          )),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {});
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}

class MyMap extends StatefulWidget {
  final void Function(LatLng) onMarkerPositionChanged;
  final initialPosition;
  final String type;
  const MyMap(
      {super.key,
      required this.onMarkerPositionChanged,
      required this.initialPosition,
      required this.type});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final _mapController = MapController();
  late LatLng marker;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    marker = widget.initialPosition;
  }

  // LatLng _marker = LatLng(24.8607, 67.0011);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: widget.initialPosition,
          zoom: 13.0,
          onTap: (tapPosition, point) {
            // print(tapPosition);
            // print(point);
            if (widget.type != "ViewOnly") {
              setState(() {
                marker = point;
              });
            }

            widget.onMarkerPositionChanged.call(marker);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: marker,
                width: 50,
                height: 50,
                builder: (context) => Icon(Icons.location_on), //FlutterLogo(),
              ),
            ],
          ),
        ],
        nonRotatedChildren: [
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () =>
                    launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GlobalSnackbar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3), // Optional duration
      ),
    );
  }
}
