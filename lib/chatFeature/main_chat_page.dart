//import 'package:cloud_firestore/cloud_firestore.dart'; --not needed?
import 'package:flutter/material.dart';
//import 'package:job_findr/chatFeature/user_search.dart'; --not needed?
import 'package:job_findr/views/constants/constants.dart';
import 'chat_list.dart';
//import 'chat_page.dart'; --not needed?

class MainChatPage extends StatefulWidget {
  const MainChatPage({super.key});

  @override
  State<MainChatPage> createState() => _MainChatPageState();
}

class _MainChatPageState extends State<MainChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundwhite,
      body: UserListPage(
        user: '',
        receiverUserId: '',
      ),
    );
  }
}
