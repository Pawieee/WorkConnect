//import 'package:firebase_auth/firebase_auth.dart'; --not needed?
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:job_findr/models/jobs.dart';
import 'package:job_findr/services/user_service.dart';
import 'package:job_findr/services/auth.dart';

class JobService {
  JobService({required this.uid});

  final String uid;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('User');

  final AuthService _auth = AuthService();

  DocumentReference get _userRef => userCollection.doc(uid);

  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  int documentLimit = 20;

  DocumentSnapshot? get lastDoc => lastDocument;

  bool get hasMoreData => hasMore;

  Future<void> addJobOpening(
      String title,
      String description,
      String location,
      int minSalary,
      int maxSalary,
      String jobType,
      String requirements,
      List<String> skillsRequired,
      String imageUrl) async {
    try {
      await _userRef.collection('JobOpenings').add({
        'jobTitle': title,
        'description': description,
        'location': location,
        'minimumSalary': minSalary,
        'maximumSalary': maxSalary,
        'jobType': jobType,
        'skillsRequired': skillsRequired,
        'requirements': requirements,
        'owner': uid,
        'isOpened': true,
        'image': imageUrl,
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<JobData>> fetchInitialJob(
      UserService userService, String uid) async {
    try {
      // Fetch the list of job IDs the user has interacted with
      List<String> interactedJobIds =
          await userService.fetchInteractedJobIds(uid);

      // Fetch job openings across all users with an optional filter
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('JobOpenings')
          //.where('isOpened', isEqualTo: true)  // Uncomment if needed
          .limit(documentLimit) // Limit the number of documents fetched
          .get();

      // Check if there are more documents to fetch
      if (snapshot.docs.isEmpty) {
        hasMore = false; // No more documents available
      } else {
        lastDocument =
            snapshot.docs.last; // Store the last document for pagination
      }

      // Filter out interacted jobs and convert to JobData instances
      return snapshot.docs
          .where((doc) =>
              !interactedJobIds.contains(doc.id)) // Exclude interacted jobs
          .map((doc) =>
              _jobDataFromSnapshot(doc)) // Ensure this function works correctly
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow; // Propagate the error for handling upstream
    }
  }

  Future<List<JobData>> fetchMoreJobs(
      UserService userService, String uid) async {
    if (!hasMore) return [];
    List<String> interactedJobIds =
        await userService.fetchInteractedJobIds(uid);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collectionGroup('JobOpenings')
        .startAfterDocument(lastDocument!)
        .limit(documentLimit)
        .get();

    if (snapshot.docs.isEmpty) {
      hasMore = false;
      return [];
    }

    lastDocument = snapshot.docs.last;

    return snapshot.docs
        .where((doc) =>
            !interactedJobIds.contains(doc.id)) // Exclude interacted jobs
        .map((doc) => _jobDataFromSnapshot(doc))
        .toList();
  }

  JobData _jobDataFromSnapshot(DocumentSnapshot snapshot) {
    return JobData(
      uid: uid,
      owner: snapshot.get('owner'),
      jobTitle: snapshot.get('jobTitle'),
      jobDescription: snapshot.get('description'),
      location: snapshot.get('location'),
      minSalaryRange: snapshot.get('minimumSalary').toString(),
      maxSalaryRange: snapshot.get('maximumSalary').toString(),
      jobType: snapshot.get('jobType'),
      skillsRequired: List<String>.from(snapshot.get('skillsRequired')),
      otherRequirements: snapshot.get('requirements'),
      isOpened: snapshot.get('isOpened'),
      jobUid: snapshot.id,
      image: snapshot.get('image') ?? '',
    );
  }

  Stream<List<JobData>> get jobOpenings {
    return _userRef.collection('JobOpenings').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => _jobDataFromSnapshot(doc)).toList());
  }

  Future<String?> getOwnerName(String ownerUid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(ownerUid)
          .get();

      if (userDoc.exists) {
        return userDoc.get('name');
      }
      return null; // Return null if user document does not exist
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // get the the data in each document in the subcollection pending_applicants and return the map

  Future<Map<String, dynamic>> getPendingApplicants(String jobUid) async {
    try {
      // Fetch the job document to ensure it exists
      DocumentSnapshot jobDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(_auth.getCurrentUserId()!)
          .collection('JobOpenings')
          .doc(jobUid)
          .get();

      if (jobDoc.exists) {
        // Access the pending_applicants subcollection
        QuerySnapshot applicantsSnapshot =
            await jobDoc.reference.collection('pending_applicants').get();

        // Initialize a map to store applicant data
        Map<String, dynamic> applicantsMap = {};

        // Loop through the documents in the subcollection
        for (var applicantDoc in applicantsSnapshot.docs) {
          applicantsMap[applicantDoc.id] =
              applicantDoc.data(); // Store each document's data in the map
        }

        return applicantsMap; // Return the populated map
      }
      return {}; // Return an empty map if the job document does not exist
    } catch (e) {
      log(e.toString()); // Log the error
      print('error ${e.toString()}');
      rethrow; // Propagate the error for handling upstream
    }
  }

  // delete applicant from pending_applicants subcollection
  Future<void> deleteApplicant(String jobUid, String applicantUid) async {
    try {
      // Fetch the job document to ensure it exists
      DocumentSnapshot jobDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(_auth.getCurrentUserId()!)
          .collection('JobOpenings')
          .doc(jobUid)
          .get();

      if (jobDoc.exists) {
        // Access the pending_applicants subcollection
        DocumentSnapshot applicantDoc = await jobDoc.reference
            .collection('pending_applicants')
            .doc(applicantUid)
            .get();

        if (applicantDoc.exists) {
          // Delete the applicant from the pending_applicants subcollection
          await jobDoc.reference
              .collection('pending_applicants')
              .doc(applicantUid)
              .delete();

          print('Applicant deleted successfully');
        } else {
          log("Applicant document does not exist.");
        }
      } else {
        log("Job document does not exist.");
      }
    } catch (e) {
      log(e.toString()); // Log the error
      rethrow; // Propagate the error for handling upstream
    }
  }

  Stream<Map<String, Map<String, dynamic>>> getAcceptedApplicantsStream(
      String jobUid) {
    return FirebaseFirestore.instance
        .collection('User')
        .doc(_auth.getCurrentUserId()!)
        .collection('JobOpenings')
        .doc(jobUid)
        .collection('accepted_applicants')
        .snapshots()
        .map((snapshot) {
      Map<String, Map<String, dynamic>> applicantsMap = {};
      for (var applicantDoc in snapshot.docs) {
        applicantsMap[applicantDoc.id] =
            applicantDoc.data(); // Ensure type safety
      }
      return applicantsMap; // Return the populated map
    });
  }

  Stream<Map<String, Map<String, dynamic>>> getPendingApplicantsStream(
      String jobUid) {
    return FirebaseFirestore.instance
        .collection('User')
        .doc(_auth.getCurrentUserId()!)
        .collection('JobOpenings')
        .doc(jobUid)
        .collection('pending_applicants')
        .snapshots()
        .map((snapshot) {
      Map<String, Map<String, dynamic>> applicantsMap = {};
      for (var applicantDoc in snapshot.docs) {
        applicantsMap[applicantDoc.id] =
            applicantDoc.data(); // Ensure type safety
      }
      return applicantsMap; // Return the populated map
    });
  }

  Future<Map<String, Map<String, dynamic>>> getPendingApplicantsList(
      String jobUid) async {
    try {
      // Fetch the job document to ensure it exists
      DocumentSnapshot jobDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(_auth.getCurrentUserId()!)
          .collection('JobOpenings')
          .doc(jobUid)
          .get();

      if (jobDoc.exists) {
        // Access the pending_applicants subcollection
        QuerySnapshot applicantsSnapshot =
            await jobDoc.reference.collection('pending_applicants').get();

        // Initialize a map to store applicant data
        Map<String, Map<String, dynamic>> applicantsMap = {};

        // Loop through the documents in the subcollection
        for (var applicantDoc in applicantsSnapshot.docs) {
          applicantsMap[applicantDoc.id] =
              applicantDoc.data() as Map<String, dynamic>; // Ensure type safety
        }
        return applicantsMap; // Return the populated map
      }

      print('jobuid: $jobUid');

      return {}; // Return an empty map if the job document does not exist
    } catch (e) {
      log('Error fetching pending applicants: ${e.toString()}'); // Log the error
      rethrow; // Propagate the error for handling upstream
    }
  }

  // get the count of how many the documents in the subcollection pending_applicants
  Future<int> getPendingApplicantsCount(String jobUid) async {
    try {
      // Fetch the job document to ensure it exists
      DocumentSnapshot jobDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(_auth.getCurrentUserId()!)
          .collection('JobOpenings')
          .doc(jobUid)
          .get();

      if (jobDoc.exists) {
        // Access the pending_applicants subcollection
        QuerySnapshot applicantsSnapshot =
            await jobDoc.reference.collection('pending_applicants').get();

        return applicantsSnapshot.size; // Return the number of documents
      }
      return 0; // Return 0 if the job document does not exist
    } catch (e) {
      log(e.toString()); // Log the error
      rethrow; // Propagate the error for handling upstream
    }
  }

  // add applicant to accepted_applicants subcollection
  Future<void> acceptApplicant(String jobUid, String applicantUid) async {
    try {
      // Fetch the job document to ensure it exists
      DocumentSnapshot jobDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(_auth.getCurrentUserId()!)
          .collection('JobOpenings')
          .doc(jobUid)
          .get();

      if (jobDoc.exists) {
        // Access the pending_applicants subcollection
        DocumentSnapshot applicantDoc = await jobDoc.reference
            .collection('pending_applicants')
            .doc(applicantUid)
            .get();

        if (applicantDoc.exists) {
          // Retrieve the data and check if it's valid
          final data = applicantDoc.data();
          if (data != null && data is Map<String, dynamic>) {
            // Add the applicant to the accepted_applicants subcollection
            await jobDoc.reference
                .collection('accepted_applicants')
                .doc(applicantUid)
                .set(data);

            // Delete the applicant from the pending_applicants subcollection
            await jobDoc.reference
                .collection('pending_applicants')
                .doc(applicantUid)
                .delete();

            print('Applicant accepted successfully');
          } else {
            log("Applicant document data is null or not of the expected type.");
          }
        } else {
          log("Applicant document does not exist.");
        }
      } else {
        log("Job document does not exist.");
      }
    } catch (e) {
      log(e.toString()); // Log the error
      rethrow; // Propagate the error for handling upstream
    }
  }
}
