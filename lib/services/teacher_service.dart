import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teacher_connect/models/teacher_profile.dart';
import 'dart:io';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current teacher profile
  Future<TeacherProfile?> getCurrentTeacherProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('teachers')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return TeacherProfile.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting teacher profile: $e');
      rethrow;
    }
  }

  // Create or update teacher profile
  Future<void> saveTeacherProfile(TeacherProfile profile) async {
    try {
      await _firestore
          .collection('teachers')
          .doc(profile.userId)
          .set(profile.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving teacher profile: $e');
      rethrow;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      String fileName = 'profile_images/$userId.jpg';
      Reference ref = _storage.ref().child(fileName);
      
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  // Upload qualification certificate
  Future<String> uploadCertificate(File certificateFile, String userId, String qualificationId) async {
    try {
      String fileName = 'certificates/$userId/$qualificationId.pdf';
      Reference ref = _storage.ref().child(fileName);
      
      UploadTask uploadTask = ref.putFile(certificateFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading certificate: $e');
      rethrow;
    }
  }

  // Get all teachers (for admin)
  Future<List<TeacherProfile>> getAllTeachers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('teachers')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TeacherProfile.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all teachers: $e');
      rethrow;
    }
  }

  // Get verified teachers
  Future<List<TeacherProfile>> getVerifiedTeachers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('teachers')
          .where('isVerified', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TeacherProfile.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting verified teachers: $e');
      rethrow;
    }
  }

  // Search teachers by criteria
  Future<List<TeacherProfile>> searchTeachers({
    List<String>? subjects,
    String? location,
    int? minExperience,
    bool? isPremium,
  }) async {
    try {
      Query query = _firestore
          .collection('teachers')
          .where('isVerified', isEqualTo: true)
          .where('isAvailable', isEqualTo: true);

      if (subjects != null && subjects.isNotEmpty) {
        query = query.where('subjects', arrayContainsAny: subjects);
      }

      if (location != null && location.isNotEmpty) {
        query = query.where('location', isEqualTo: location);
      }

      if (minExperience != null) {
        query = query.where('yearsOfExperience', isGreaterThanOrEqualTo: minExperience);
      }

      if (isPremium != null) {
        query = query.where('isPremium', isEqualTo: isPremium);
      }

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => TeacherProfile.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching teachers: $e');
      rethrow;
    }
  }

  // Verify teacher (admin function)
  Future<void> verifyTeacher(String teacherId, bool isVerified) async {
    try {
      await _firestore
          .collection('teachers')
          .doc(teacherId)
          .update({
        'isVerified': isVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error verifying teacher: $e');
      rethrow;
    }
  }

  // Update subscription status
  Future<void> updateSubscriptionStatus(String teacherId, bool isPremium, DateTime? expiryDate) async {
    try {
      await _firestore
          .collection('teachers')
          .doc(teacherId)
          .update({
        'isPremium': isPremium,
        'subscriptionExpiry': expiryDate?.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating subscription: $e');
      rethrow;
    }
  }

  // Get teacher statistics
  Future<Map<String, int>> getTeacherStatistics() async {
    try {
      // Total teachers
      QuerySnapshot totalSnapshot = await _firestore.collection('teachers').get();
      int total = totalSnapshot.docs.length;

      // Verified teachers
      QuerySnapshot verifiedSnapshot = await _firestore
          .collection('teachers')
          .where('isVerified', isEqualTo: true)
          .get();
      int verified = verifiedSnapshot.docs.length;

      // Premium teachers
      QuerySnapshot premiumSnapshot = await _firestore
          .collection('teachers')
          .where('isPremium', isEqualTo: true)
          .get();
      int premium = premiumSnapshot.docs.length;

      // Available teachers
      QuerySnapshot availableSnapshot = await _firestore
          .collection('teachers')
          .where('isAvailable', isEqualTo: true)
          .get();
      int available = availableSnapshot.docs.length;

      return {
        'total': total,
        'verified': verified,
        'premium': premium,
        'available': available,
      };
    } catch (e) {
      print('Error getting teacher statistics: $e');
      rethrow;
    }
  }

  // Stream teacher profile changes
  Stream<TeacherProfile?> streamTeacherProfile(String userId) {
    return _firestore
        .collection('teachers')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return TeacherProfile.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}
