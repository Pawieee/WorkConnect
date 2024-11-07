import 'package:job_findr/models/jobs.dart';
import 'package:job_findr/models/user.dart';

class JobMatcher {
  //DocumentSnapshot? lastDocument;

  List<JobData> recommendJobsForUser(UserData user, List<JobData> jobs) {
    List<JobData> recommendedJobs = [];
    for (var job in jobs) {
      int matchingSkillsCount = user.skills!
          .where((skill) => job.skillsRequired!.contains(skill))
          .length;

      if (matchingSkillsCount > 0) {
        recommendedJobs.add(job);
      }
    }
    return recommendedJobs;
  }
}
