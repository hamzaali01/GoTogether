import 'package:firebase_proj/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/user_repository.dart';

class PlanDiscussion extends StatefulWidget {
  final String planId;
  final String name;

  PlanDiscussion({required this.planId, required this.name});

  @override
  _PlanDiscussionState createState() => _PlanDiscussionState();
}

class _PlanDiscussionState extends State<PlanDiscussion> {
  final TextEditingController _messageController = TextEditingController();

  Stream<QuerySnapshot> getMessagesStream(String planId) {
    return FirebaseFirestore.instance
        .collection('plans')
        .doc(planId)
        .collection('discussions')
        .orderBy('timestamp')
        .snapshots();
  }

  void _sendMessage() {
    final String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('plans')
          .doc(widget.planId)
          .collection('discussions')
          .add({
        'senderId': Auth().currentUser!.uid,
        'senderName': widget.name,
        'message': messageText,
        'timestamp': Timestamp.now(),
      });

      _messageController.clear();
    }
  }

  Widget messageBubble(String senderName, String message, bool isMe) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            senderName,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
              bottomLeft: isMe ? Radius.circular(30.0) : Radius.circular(0.0),
              bottomRight: isMe ? Radius.circular(0.0) : Radius.circular(30.0),
            ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan Discussions'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMessagesStream(widget.planId),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  List<Widget> messageWidgets =
                      snapshot.data!.docs.map((DocumentSnapshot doc) {
                    final String senderId = doc['senderId'];
                    final String message = doc['message'];
                    final Timestamp timestamp = doc['timestamp'];
                    // return messageBubble2(senderId, message, true, timestamp);

                    if (Auth().currentUser!.uid == senderId)
                      return messageBubble(widget.name, message, true);
                    else
                      return messageBubble(widget.name, message, false);
                  }).toList();

                  // FutureBuilder<DocumentSnapshot>(
                  //   future: UserRepository().getUserById(senderId),
                  //   builder: (BuildContext context,
                  //       AsyncSnapshot<DocumentSnapshot> snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.done) {
                  //       Map<String, dynamic> userData =
                  //           snapshot.data!.data() as Map<String, dynamic>;
                  //       final String senderName = userData['name'];
                  //       if (Auth().currentUser!.uid == senderId)
                  //         return messageBubble(senderName, message, true);
                  //       else
                  //         return messageBubble(senderName, message, false);
                  //       // return ListTile(
                  //       //   title: Text(senderName),
                  //       //   subtitle: Text(message),
                  //       //   trailing: Text(timestamp.toString()),
                  //       // );
                  //     } else if (snapshot.connectionState ==
                  //         ConnectionState.waiting) {
                  //       return Center(child: CircularProgressIndicator());
                  //     } else {
                  //       return Center(
                  //         child: Text(
                  //           "Error",
                  //           style: TextStyle(fontSize: 10),
                  //         ),
                  //       );
                  //     }
                  //   },
                  // );

                  return ListView(
                    reverse: false,
                    children: messageWidgets,
                  );
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
