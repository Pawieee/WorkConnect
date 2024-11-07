import 'package:flutter/material.dart';
import 'package:job_findr/views/constants/constants.dart';
//import 'package:job_findr/views/home/employer_homepage.dart'; --not needed?
//import 'package:job_findr/views/home/employer_profile.dart'; --not needed?
import 'package:job_findr/views/home/job_details.dart';
import 'package:job_findr/views/home/job_opening.dart';
import 'package:job_findr/services/job_service.dart';
import 'package:job_findr/views/constants/loading.dart';
import 'package:job_findr/services/auth.dart';
import 'package:job_findr/models/jobs.dart';
import 'package:job_findr/services/user_service.dart';

class EmployerPositions extends StatefulWidget {
  const EmployerPositions({super.key});

  @override
  State<EmployerPositions> createState() => _EmployerPositionsState();
}

class _EmployerPositionsState extends State<EmployerPositions> {
  late AuthService _auth;
  final int _currentIndex = 0;
  late UserService _userService;
  late JobService _jobService;

  @override
  void initState() {
    super.initState();
    _auth = AuthService();
    _userService = UserService(uid: _auth.getCurrentUserId()!);
    _jobService = JobService(uid: _auth.getCurrentUserId()!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Job Positions'),
        titleTextStyle: headingStyle_white,
        backgroundColor: primarycolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<JobData>>(
          stream: JobService(uid: _auth.getCurrentUserId()!).jobOpenings,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            if (snapshot.hasData) {
              return _buildJobPositions(snapshot.data!);
            }

            return const Loading();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobOpeningForm()),
          );
        },
        backgroundColor: accent2,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildJobPositions(List<JobData> jobPositions) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: jobPositions.length,
      itemBuilder: (context, index) {
        final job = jobPositions[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailsPage(jobData: job),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: secondarycolor,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: backgroundblack,
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Title: ${job.jobTitle!}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 1.5,
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: Text(
                          job.jobDescription!,
                          style: TextStyle(fontSize: 16),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //Positioned(
              //  top: -10,
              //  right: -10,
              //  child: notificationCount > 0
              //      ? Container(
              //          padding: EdgeInsets.all(5.0),
              //          decoration: BoxDecoration(
              //            color: Colors.red,
              //            shape: BoxShape.circle,
              //          ),
              //          child: Text(
              //            '$notificationCount',
              //            style: TextStyle(
              //              color: Colors.white,
              //              fontSize: 12.0,
              //              fontWeight: FontWeight.bold,
              //            ),
              //          ),
              //        )
              //      : Container(),
              //),
            ],
          ),
        );
      },
    );
  }
}
