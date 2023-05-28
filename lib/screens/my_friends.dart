import 'package:flutter/material.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_proj/repositories/user_repository.dart';

import '../widgets/widgets.dart';

class MyFriends extends StatefulWidget {
  final String uid;
  MyFriends({required this.uid});

  @override
  State<MyFriends> createState() => _MyFriendsState();
}

class _MyFriendsState extends State<MyFriends> {
  final TextEditingController _controllerAddFriend = TextEditingController();

  // final User? user = Auth().currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text("My Friends"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refetch the data from Firestore
          await UserRepository().getFriendsByUid(widget.uid);
          // Set the state with the new data
          setState(() {});
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "Enter Friend's Username",
                style: TextStyle(fontSize: 18),
              ),
              Padding(
                // padding: const EdgeInsets.all(50.0),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: TextField(
                  controller: _controllerAddFriend,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        )),
                    //  labelText: "Enter Friend's Username",
                    //labelStyle: TextStyle(color: Colors.black, fontSize: 18)
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    String status = await UserRepository()
                        .addFriend(_controllerAddFriend.text, widget.uid);
                    setState(() {});
                    if (status == "Success") {
                      GlobalSnackbar.show(context, "Friend Added Succesfully");
                    } else if (status == "Not Found") {
                      GlobalSnackbar.show(
                          context, "No Friend Found with this Username");
                    } else {
                      GlobalSnackbar.show(
                          context, "Some error occured while adding Friend");
                    }
                  },
                  child: Text("Add Friend")),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 200,
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: UserRepository().getFriendsByUid(widget.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return Text('No Friends found.');
                    } else {
                      final friends = snapshot.data!;
                      if (friends.length == 0) {
                        return Text("No Friends found");
                      }

                      return ListView.builder(
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          // final plan = plans[index].data();
                          final friend =
                              friends[index].data() as Map<String, dynamic>?;
                          final name = friend?['name'];
                          final username = friend?['username'];
                          final pictureUrl = friend?['profilePictureUrl'];

                          return Card(
                            child: SizedBox(
                              height: 60,
                              child: ListTile(
                                leading: CircleAvatar(
                                    radius: 28,
                                    backgroundImage: NetworkImage(pictureUrl!),
                                    child: pictureUrl == ""
                                        ? Icon(Icons.person)
                                        : null),
                                title: Text(
                                  name ?? 'No name',
                                  style: TextStyle(fontSize: 20),
                                ),
                                // subtitle: Text(username ?? 'No username'),
                                onTap: () {
                                  // print("Opening Friend Data " +
                                  //     friends[index].data().toString());
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Center(
                                            child: Text('Friend Details')),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: CircleAvatar(
                                                radius: 100,
                                                backgroundImage: pictureUrl !=
                                                        null
                                                    ? NetworkImage(pictureUrl!)
                                                    : null,
                                                child: pictureUrl == null
                                                    ? Icon(Icons.person_2)
                                                    : null,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Center(
                                                child: Text(
                                              name,
                                              style: TextStyle(fontSize: 30),
                                            )),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Center(
                                                child: Text(
                                                    "username: " + username,
                                                    style: TextStyle(
                                                        fontSize: 20))),
                                          ],
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
