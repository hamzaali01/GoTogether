import 'package:flutter/material.dart';
import 'package:firebase_proj/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_proj/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/my_friends/my_friends_bloc.dart';
import '../common_widgets/widgets.dart';

class MyFriends extends StatefulWidget {
  final String uid;
  final FirebaseFirestore firestore;

  MyFriends({required this.uid, required this.firestore});

  @override
  State<MyFriends> createState() => _MyFriendsState();
}

class _MyFriendsState extends State<MyFriends> {
  final TextEditingController _controllerAddFriend = TextEditingController();

  // final User? user = Auth().currentUser;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyFriendsBloc(firestore: widget.firestore)
        ..add(GetMyFriendsEvent(widget.uid)),
      child: Scaffold(
        //  backgroundColor: Color.fromARGB(255, 255, 255, 255),
        drawer: MyDrawer(
          uid: widget.uid,
        ),
        appBar: AppBar(
          title: title("My Friends", [Colors.white, Colors.white]),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // Colors.blue.shade800,
                  Color.fromARGB(255, 0, 255, 128),
                  Color.fromARGB(255, 32, 192, 4),

                  // Color.fromARGB(255, 171, 135, 255),
                  // Color(0xFF5F53B7),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: BlocBuilder<MyFriendsBloc, MyFriendsState>(
            builder: (context, state) {
              if (state is LoadingState) {
                return Center(
                    child: CircularProgressIndicator(
                        //backgroundColor: Colors.blue,
                        ));
              } else if (state is LoadedState) {
                final friends = state.friends;
                if (state.status != "") {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    GlobalSnackbar.show(context, state.status);
                  });
                }

                return Column(
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
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 40),
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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 0, 180, 81)),
                        onPressed: () async {
                          BlocProvider.of<MyFriendsBloc>(context).add(
                              AddFriendEvent(
                                  _controllerAddFriend.text, widget.uid));
                          GlobalSnackbar.show(context, "Adding Friend");
                        },
                        child: Text("Add Friend")),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Your Friends (" + friends.length.toString() + ")",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      child: Container(
                        height: 400,
                        child: ListView.builder(
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            // final plan = plans[index].data();
                            final friend =
                                friends[index].data() as Map<String, dynamic>?;
                            final name = friend?['name'];
                            final username = friend?['username'];
                            final pictureUrl = friend?['profilePictureUrl'];

                            return Card(
                              elevation: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      // Colors.blue.shade800,
                                      Color.fromARGB(255, 46, 247, 66),
                                      Color.fromARGB(255, 255, 255, 255),
                                      Color.fromARGB(255, 46, 247, 66),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                      radius: 28,
                                      backgroundImage: pictureUrl != ''
                                          ? NetworkImage(pictureUrl!)
                                          : null,
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
                                                  backgroundImage:
                                                      pictureUrl != ''
                                                          ? NetworkImage(
                                                              pictureUrl!)
                                                          : null,
                                                  child: pictureUrl == ""
                                                      ? Icon(Icons.person)
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
                        ),
                      ),
                    ),
                  ],
                );
              } else if (state is ErrorState) {
                return Text(state.errorMessage);
              } else {
                return Text("");
              }
            },
          ),
        ),
      ),
    );
  }
}
