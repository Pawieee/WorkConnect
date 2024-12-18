import 'package:job_findr/models/education.dart';
import 'package:job_findr/models/experience.dart';
import 'package:job_findr/models/certification.dart';

class User {
  final String? uid;

  User({
    required this.uid,
  });
}

class UserData {
  final String? uid;
  final String? name;
  final String? email;
  final String? gender;
  final DateTime? birthDate;
  final String? phone;
  final String? address;
  final bool? isJobSeeker;
  final String? website;
  final bool? isUserNew;
  final String? profilePicture;
  List<dynamic>? skills;
  List<Education>? education;
  List<Experience>? experience;
  List<Certification>? certifications;

  UserData(
      {required this.uid,
      required this.name,
      required this.email,
      required this.gender,
      required this.birthDate,
      required this.phone,
      required this.address,
      required this.isJobSeeker,
      required this.website,
      required this.isUserNew,
      required this.profilePicture,
      this.skills,
      this.education,
      this.experience,
      this.certifications});
}
