class TeacherProfile {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String? profileImageUrl;
  final String? bio;
  final List<Qualification> qualifications;
  final List<String> subjects;
  final List<String> skills;
  final List<String> languages;
  final int yearsOfExperience;
  final String? currentPosition;
  final String? preferredJobType; // full-time, part-time, contract
  final double? expectedSalary;
  final bool isVerified;
  final bool isPremium;
  final bool isAvailable;
  final DateTime? subscriptionExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeacherProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    this.profileImageUrl,
    this.bio,
    required this.qualifications,
    required this.subjects,
    required this.skills,
    this.languages = const ['English'],
    this.yearsOfExperience = 0,
    this.currentPosition,
    this.preferredJobType,
    this.expectedSalary,
    this.isVerified = false,
    this.isPremium = false,
    this.isAvailable = true,
    this.subscriptionExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method for creating from JSON
  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      qualifications: (json['qualifications'] as List<dynamic>?)
          ?.map((q) => Qualification.fromJson(q))
          .toList() ?? [],
      subjects: List<String>.from(json['subjects'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      languages: List<String>.from(json['languages'] ?? ['English']),
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      currentPosition: json['currentPosition'],
      preferredJobType: json['preferredJobType'],
      expectedSalary: json['expectedSalary']?.toDouble(),
      isVerified: json['isVerified'] ?? false,
      isPremium: json['isPremium'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      subscriptionExpiry: json['subscriptionExpiry'] != null
          ? DateTime.parse(json['subscriptionExpiry'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'qualifications': qualifications.map((q) => q.toJson()).toList(),
      'subjects': subjects,
      'skills': skills,
      'languages': languages,
      'yearsOfExperience': yearsOfExperience,
      'currentPosition': currentPosition,
      'preferredJobType': preferredJobType,
      'expectedSalary': expectedSalary,
      'isVerified': isVerified,
      'isPremium': isPremium,
      'isAvailable': isAvailable,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // CopyWith method for updates
  TeacherProfile copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? profileImageUrl,
    String? bio,
    List<Qualification>? qualifications,
    List<String>? subjects,
    List<String>? skills,
    List<String>? languages,
    int? yearsOfExperience,
    String? currentPosition,
    String? preferredJobType,
    double? expectedSalary,
    bool? isVerified,
    bool? isPremium,
    bool? isAvailable,
    DateTime? subscriptionExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      qualifications: qualifications ?? this.qualifications,
      subjects: subjects ?? this.subjects,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      currentPosition: currentPosition ?? this.currentPosition,
      preferredJobType: preferredJobType ?? this.preferredJobType,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      isAvailable: isAvailable ?? this.isAvailable,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Qualification {
  final String id;
  final String degree;
  final String institution;
  final String year;
  final String? certificateUrl;
  final String? grade;
  final String? fieldOfStudy;
  final bool isVerified;

  Qualification({
    required this.id,
    required this.degree,
    required this.institution,
    required this.year,
    this.certificateUrl,
    this.grade,
    this.fieldOfStudy,
    this.isVerified = false,
  });

  // Factory method for creating from JSON
  factory Qualification.fromJson(Map<String, dynamic> json) {
    return Qualification(
      id: json['id'] ?? '',
      degree: json['degree'] ?? '',
      institution: json['institution'] ?? '',
      year: json['year'] ?? '',
      certificateUrl: json['certificateUrl'],
      grade: json['grade'],
      fieldOfStudy: json['fieldOfStudy'],
      isVerified: json['isVerified'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'degree': degree,
      'institution': institution,
      'year': year,
      'certificateUrl': certificateUrl,
      'grade': grade,
      'fieldOfStudy': fieldOfStudy,
      'isVerified': isVerified,
    };
  }

  // CopyWith method
  Qualification copyWith({
    String? id,
    String? degree,
    String? institution,
    String? year,
    String? certificateUrl,
    String? grade,
    String? fieldOfStudy,
    bool? isVerified,
  }) {
    return Qualification(
      id: id ?? this.id,
      degree: degree ?? this.degree,
      institution: institution ?? this.institution,
      year: year ?? this.year,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      grade: grade ?? this.grade,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}