import 'package:flutter/material.dart';
import 'package:only_job/views/constants/constants.dart';
import 'package:only_job/views/home/employer_homepage.dart';
import 'package:only_job/views/home/employer_profile.dart';
import 'package:only_job/views/home/job_details.dart';
import 'package:only_job/views/home/job_opening.dart';
import 'package:only_job/services/job_service.dart';
import 'package:only_job/views/constants/loading.dart';
import 'package:only_job/services/auth.dart';
import 'package:only_job/models/jobs.dart';
import 'package:only_job/services/user_service.dart';

class EmployerPositions extends StatefulWidget {
  const EmployerPositions({super.key});

  @override
  State<EmployerPositions> createState() => _EmployerPositionsState();
}

class _EmployerPositionsState extends State<EmployerPositions> {
  late AuthService _auth;
  int _currentIndex = 0;
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
        child: const Icon(Icons.add),
        backgroundColor: accent2,
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
                        'Job Title: ' + job.jobTitle!,
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
