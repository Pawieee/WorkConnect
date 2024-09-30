import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:only_job/chatFeature/displayMessage.dart';

import '../models/message.dart';
import '../services/auth.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final AuthService authService = AuthService();

  String? currentUserName;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserName();
  }

  void fetchCurrentUserName() async {
    currentUserName = await authService.getCurrentUserName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    String receiverName = widget.user['name'] ?? 'Unknown';



    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page'),
        actions: [
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            color: Colors.blueAccent,
            onPressed: () {
              // Sign out functionality
              auth.signOut();
            },
            child: Text('Sign out'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: DisplayMessage(user: currentUserName ?? 'user'),

            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "Message",
                        contentPadding: EdgeInsets.only(left: 15, bottom: 8, top: 8),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (value) {
                        return null;
                      },
                      onSaved: (value) {
                        messageController.text = value!;
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (messageController.text.isNotEmpty) {
                        // Create a Message object
                        Message newMessage = Message(
                          message: messageController.text.trim(),
                          time: DateTime.now(),
                          senderName: currentUserName ?? 'Unknown',
                          receiver: receiverName,
                        );

                        String currentUserId = auth.currentUser?.uid ?? '';
                        String receiverUserId = widget.user['uid'] ?? '';

                        DocumentReference receiverDocRef = firebaseFirestore.collection('User').doc(receiverUserId);

                        String messageId = DateTime.now().millisecondsSinceEpoch.toString();

                        await receiverDocRef.collection('messages').doc(messageId).set(newMessage.toMap());

                        DocumentReference senderDocRef = firebaseFirestore.collection('User').doc(currentUserId);
                        await senderDocRef.collection('messages').doc(messageId).set(newMessage.toMap());

                        messageController.clear();
                      }
                    },
                    icon: Icon(Icons.send, size: 30, color: Colors.blue),
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
