import 'package:flutter/material.dart';
import 'package:job_findr/services/auth.dart';
//import 'package:provider/provider.dart'; --not needed?
import 'package:job_findr/models/user.dart';
import 'package:job_findr/services/user_service.dart';
import 'package:job_findr/views/constants/loading.dart';
// import 'package:job_findr/views/home/homepageJS.dart'; --not needed?
import 'package:job_findr/views/home/employer_homepage.dart';
import 'package:job_findr/views/JS_view/job_seeker_nav.dart';
import 'package:job_findr/views/authenticate/introduction.dart';

class Home extends StatefulWidget {
  Home({super.key, required this.uid});
  String uid;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService(); //--not needed?
  bool isUserNew = true;

  void setUserNotNew() {
    setState(() {
      isUserNew = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserData>(
      stream: UserService(uid: widget.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (snapshot.hasData) {
          UserData userData = snapshot.data!;
          if (userData.isUserNew!) {
            return IntroPage(setUserNotNew: setUserNotNew);
          }

          if (userData.isJobSeeker!) {
            return NavJS();
          }

          return ClientHomePage();
        }

        return const Loading();
      },
    );
  }
}
