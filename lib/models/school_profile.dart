class SchoolProfile {
  final String id;
  final String userId;
  final String schoolName;
  final String email;
  final String phone;
  final String location;
  final String? logoUrl;
  final String? description;
  final String schoolType; // primary, secondary, university, college
  final String? website;
  final List<String> facilities;
  final int? numberOfStudents;
  final int? numberOfTeachers;
  final bool isVerified;
  final bool isPremium;
  final DateTime? subscriptionExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  SchoolProfile({
    required this.id,
    required this.userId,
    required this.schoolName,
    required this.email,
    required this.phone,
    required this.location,
    this.logoUrl,
    this.description,
    required this.schoolType,
    this.website,
    this.facilities = const [],
    this.numberOfStudents,
    this.numberOfTeachers,
    this.isVerified = false,
    this.isPremium = false,
    this.subscriptionExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method for creating from JSON
  factory SchoolProfile.fromJson(Map<String, dynamic> json) {
    return SchoolProfile(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      schoolName: json['schoolName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      logoUrl: json['logoUrl'],
      description: json['description'],
      schoolType: json['schoolType'] ?? '',
      website: json['website'],
      facilities: List<String>.from(json['facilities'] ?? []),
      numberOfStudents: json['numberOfStudents'],
      numberOfTeachers: json['numberOfTeachers'],
      isVerified: json['isVerified'] ?? false,
      isPremium: json['isPremium'] ?? false,
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
      'schoolName': schoolName,
      'email': email,
      'phone': phone,
      'location': location,
      'logoUrl': logoUrl,
      'description': description,
      'schoolType': schoolType,
      'website': website,
      'facilities': facilities,
      'numberOfStudents': numberOfStudents,
      'numberOfTeachers': numberOfTeachers,
      'isVerified': isVerified,
      'isPremium': isPremium,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // CopyWith method for updates
  SchoolProfile copyWith({
    String? id,
    String? userId,
    String? schoolName,
    String? email,
    String? phone,
    String? location,
    String? logoUrl,
    String? description,
    String? schoolType,
    String? website,
    List<String>? facilities,
    int? numberOfStudents,
    int? numberOfTeachers,
    bool? isVerified,
    bool? isPremium,
    DateTime? subscriptionExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SchoolProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      schoolName: schoolName ?? this.schoolName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      schoolType: schoolType ?? this.schoolType,
      website: website ?? this.website,
      facilities: facilities ?? this.facilities,
      numberOfStudents: numberOfStudents ?? this.numberOfStudents,
      numberOfTeachers: numberOfTeachers ?? this.numberOfTeachers,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
