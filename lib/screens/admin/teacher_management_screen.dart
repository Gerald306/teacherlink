import 'package:flutter/material.dart';
import 'package:teacher_connect/models/teacher_profile.dart';
import 'package:teacher_connect/services/teacher_service.dart';

class TeacherManagementScreen extends StatefulWidget {
  @override
  _TeacherManagementScreenState createState() => _TeacherManagementScreenState();
}

class _TeacherManagementScreenState extends State<TeacherManagementScreen> {
  final _teacherService = TeacherService();
  List<TeacherProfile> _teachers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    // Load teachers from database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teacher Management')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _teachers.length,
              itemBuilder: (context, index) {
                // Teacher card with approve/reject actions
              },
            ),
    );
  }
}