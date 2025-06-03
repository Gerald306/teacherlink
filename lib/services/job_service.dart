import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teacher_connect/models/job_posting.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all active jobs
  Future<List<JobPosting>> getActiveJobs() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .where('applicationDeadline', isGreaterThan: DateTime.now())
          .orderBy('applicationDeadline')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => JobPosting.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting active jobs: $e');
      rethrow;
    }
  }

  // Get jobs by school
  Future<List<JobPosting>> getJobsBySchool(String schoolId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('jobs')
          .where('schoolId', isEqualTo: schoolId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => JobPosting.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting jobs by school: $e');
      rethrow;
    }
  }

  // Search jobs with filters
  Future<List<JobPosting>> searchJobs({
    String? searchText,
    List<String>? subjects,
    String? location,
    String? jobType,
    double? minSalary,
    double? maxSalary,
  }) async {
    try {
      Query query = _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .where('applicationDeadline', isGreaterThan: DateTime.now());

      if (subjects != null && subjects.isNotEmpty) {
        query = query.where('requiredSubjects', arrayContainsAny: subjects);
      }

      if (location != null && location.isNotEmpty) {
        query = query.where('location', isEqualTo: location);
      }

      if (jobType != null && jobType.isNotEmpty) {
        query = query.where('jobType', isEqualTo: jobType);
      }

      if (minSalary != null) {
        query = query.where('salaryMin', isGreaterThanOrEqualTo: minSalary);
      }

      if (maxSalary != null) {
        query = query.where('salaryMax', isLessThanOrEqualTo: maxSalary);
      }

      QuerySnapshot querySnapshot = await query.get();

      List<JobPosting> jobs = querySnapshot.docs
          .map((doc) => JobPosting.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Apply text search filter (Firestore doesn't support full-text search)
      if (searchText != null && searchText.isNotEmpty) {
        final searchLower = searchText.toLowerCase();
        jobs = jobs.where((job) {
          return job.title.toLowerCase().contains(searchLower) ||
                 job.description.toLowerCase().contains(searchLower);
        }).toList();
      }

      return jobs;
    } catch (e) {
      print('Error searching jobs: $e');
      rethrow;
    }
  }

  // Get job by ID
  Future<JobPosting?> getJobById(String jobId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('jobs').doc(jobId).get();
      
      if (doc.exists) {
        return JobPosting.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting job by ID: $e');
      rethrow;
    }
  }

  // Create job posting (for schools)
  Future<String> createJobPosting(JobPosting job) async {
    try {
      DocumentReference docRef = await _firestore.collection('jobs').add(job.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating job posting: $e');
      rethrow;
    }
  }

  // Update job posting
  Future<void> updateJobPosting(JobPosting job) async {
    try {
      await _firestore.collection('jobs').doc(job.id).update(job.toJson());
    } catch (e) {
      print('Error updating job posting: $e');
      rethrow;
    }
  }

  // Delete job posting
  Future<void> deleteJobPosting(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      print('Error deleting job posting: $e');
      rethrow;
    }
  }

  // Apply for job
  Future<void> applyForJob(String jobId, String coverLetter) async {
    try {
      String userId = _auth.currentUser!.uid;
      
      // Create job application
      JobApplication application = JobApplication(
        id: '',
        jobId: jobId,
        teacherId: userId,
        coverLetter: coverLetter,
        appliedAt: DateTime.now(),
      );

      // Add to applications collection
      DocumentReference docRef = await _firestore
          .collection('applications')
          .add(application.toJson());

      // Update job with applicant ID
      await _firestore.collection('jobs').doc(jobId).update({
        'applicantIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update application with generated ID
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('Error applying for job: $e');
      rethrow;
    }
  }

  // Get teacher's applications
  Future<List<JobApplication>> getTeacherApplications(String teacherId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('applications')
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('appliedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => JobApplication.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting teacher applications: $e');
      rethrow;
    }
  }

  // Get applications for a job (for schools)
  Future<List<JobApplication>> getJobApplications(String jobId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .orderBy('appliedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => JobApplication.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting job applications: $e');
      rethrow;
    }
  }

  // Update application status (for schools)
  Future<void> updateApplicationStatus(String applicationId, String status, {String? reviewNotes}) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
      };

      if (reviewNotes != null) {
        updateData['reviewNotes'] = reviewNotes;
      }

      await _firestore.collection('applications').doc(applicationId).update(updateData);
    } catch (e) {
      print('Error updating application status: $e');
      rethrow;
    }
  }

  // Check if teacher has already applied for job
  Future<bool> hasAppliedForJob(String jobId, String teacherId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if applied: $e');
      rethrow;
    }
  }

  // Get featured/premium jobs
  Future<List<JobPosting>> getFeaturedJobs() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .where('isPremium', isEqualTo: true)
          .where('applicationDeadline', isGreaterThan: DateTime.now())
          .orderBy('applicationDeadline')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => JobPosting.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting featured jobs: $e');
      rethrow;
    }
  }

  // Get job statistics
  Future<Map<String, int>> getJobStatistics() async {
    try {
      // Total active jobs
      QuerySnapshot totalSnapshot = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .get();
      int total = totalSnapshot.docs.length;

      // Jobs posted this week
      DateTime weekAgo = DateTime.now().subtract(Duration(days: 7));
      QuerySnapshot weekSnapshot = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .where('createdAt', isGreaterThan: weekAgo)
          .get();
      int thisWeek = weekSnapshot.docs.length;

      // Premium jobs
      QuerySnapshot premiumSnapshot = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .where('isPremium', isEqualTo: true)
          .get();
      int premium = premiumSnapshot.docs.length;

      // Total applications
      QuerySnapshot applicationsSnapshot = await _firestore
          .collection('applications')
          .get();
      int applications = applicationsSnapshot.docs.length;

      return {
        'total': total,
        'thisWeek': thisWeek,
        'premium': premium,
        'applications': applications,
      };
    } catch (e) {
      print('Error getting job statistics: $e');
      rethrow;
    }
  }

  // Stream job updates
  Stream<List<JobPosting>> streamActiveJobs() {
    return _firestore
        .collection('jobs')
        .where('isActive', isEqualTo: true)
        .where('applicationDeadline', isGreaterThan: DateTime.now())
        .orderBy('applicationDeadline')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => JobPosting.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Stream teacher applications
  Stream<List<JobApplication>> streamTeacherApplications(String teacherId) {
    return _firestore
        .collection('applications')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => JobApplication.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
