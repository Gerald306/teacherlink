class JobPosting {
  final String id;
  final String schoolId;
  final String title;
  final String description;
  final List<String> requiredSubjects;
  final List<String> requiredQualifications;
  final String jobType; // full-time, part-time, contract, temporary
  final double? salaryMin;
  final double? salaryMax;
  final String location;
  final int? yearsOfExperienceRequired;
  final List<String> benefits;
  final DateTime applicationDeadline;
  final bool isActive;
  final bool isPremium;
  final List<String> applicantIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobPosting({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.description,
    required this.requiredSubjects,
    required this.requiredQualifications,
    required this.jobType,
    this.salaryMin,
    this.salaryMax,
    required this.location,
    this.yearsOfExperienceRequired,
    this.benefits = const [],
    required this.applicationDeadline,
    this.isActive = true,
    this.isPremium = false,
    this.applicantIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method for creating from JSON
  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      id: json['id'] ?? '',
      schoolId: json['schoolId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requiredSubjects: List<String>.from(json['requiredSubjects'] ?? []),
      requiredQualifications: List<String>.from(json['requiredQualifications'] ?? []),
      jobType: json['jobType'] ?? '',
      salaryMin: json['salaryMin']?.toDouble(),
      salaryMax: json['salaryMax']?.toDouble(),
      location: json['location'] ?? '',
      yearsOfExperienceRequired: json['yearsOfExperienceRequired'],
      benefits: List<String>.from(json['benefits'] ?? []),
      applicationDeadline: DateTime.parse(json['applicationDeadline']),
      isActive: json['isActive'] ?? true,
      isPremium: json['isPremium'] ?? false,
      applicantIds: List<String>.from(json['applicantIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'title': title,
      'description': description,
      'requiredSubjects': requiredSubjects,
      'requiredQualifications': requiredQualifications,
      'jobType': jobType,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'location': location,
      'yearsOfExperienceRequired': yearsOfExperienceRequired,
      'benefits': benefits,
      'applicationDeadline': applicationDeadline.toIso8601String(),
      'isActive': isActive,
      'isPremium': isPremium,
      'applicantIds': applicantIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // CopyWith method for updates
  JobPosting copyWith({
    String? id,
    String? schoolId,
    String? title,
    String? description,
    List<String>? requiredSubjects,
    List<String>? requiredQualifications,
    String? jobType,
    double? salaryMin,
    double? salaryMax,
    String? location,
    int? yearsOfExperienceRequired,
    List<String>? benefits,
    DateTime? applicationDeadline,
    bool? isActive,
    bool? isPremium,
    List<String>? applicantIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobPosting(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredSubjects: requiredSubjects ?? this.requiredSubjects,
      requiredQualifications: requiredQualifications ?? this.requiredQualifications,
      jobType: jobType ?? this.jobType,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      location: location ?? this.location,
      yearsOfExperienceRequired: yearsOfExperienceRequired ?? this.yearsOfExperienceRequired,
      benefits: benefits ?? this.benefits,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      applicantIds: applicantIds ?? this.applicantIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class JobApplication {
  final String id;
  final String jobId;
  final String teacherId;
  final String coverLetter;
  final String status; // pending, reviewed, shortlisted, rejected, hired
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.teacherId,
    required this.coverLetter,
    this.status = 'pending',
    required this.appliedAt,
    this.reviewedAt,
    this.reviewNotes,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] ?? '',
      jobId: json['jobId'] ?? '',
      teacherId: json['teacherId'] ?? '',
      coverLetter: json['coverLetter'] ?? '',
      status: json['status'] ?? 'pending',
      appliedAt: DateTime.parse(json['appliedAt']),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      reviewNotes: json['reviewNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'teacherId': teacherId,
      'coverLetter': coverLetter,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNotes': reviewNotes,
    };
  }

  JobApplication copyWith({
    String? id,
    String? jobId,
    String? teacherId,
    String? coverLetter,
    String? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
    String? reviewNotes,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      teacherId: teacherId ?? this.teacherId,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
    );
  }
}
