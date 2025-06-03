import 'package:flutter/material.dart';
import 'package:teacher_connect/models/job_posting.dart';
import 'package:teacher_connect/services/job_service.dart';
import 'package:teacher_connect/services/auth_service.dart';
import 'package:teacher_connect/theme/app_theme.dart';
import 'package:teacher_connect/widgets/custom_button.dart';

class MyApplicationsScreen extends StatefulWidget {
  @override
  _MyApplicationsScreenState createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> with TickerProviderStateMixin {
  final _jobService = JobService();
  final _authService = AuthService();
  
  List<JobApplication> _applications = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<String> _statusFilters = ['all', 'pending', 'reviewed', 'shortlisted', 'rejected', 'hired'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _loadApplications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final applications = await _jobService.getTeacherApplications(userId);
        setState(() {
          _applications = applications;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading applications: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  List<JobApplication> get _filteredApplications {
    if (_selectedFilter == 'all') {
      return _applications;
    }
    return _applications.where((app) => app.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('My Applications'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildFilterSection(),
                  _buildStatsSection(),
                  Expanded(
                    child: _filteredApplications.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.all(20),
                            itemCount: _filteredApplications.length,
                            itemBuilder: (context, index) {
                              return _buildApplicationCard(_filteredApplications[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusFilters.map((filter) {
                final isSelected = _selectedFilter == filter;
                final count = filter == 'all' 
                    ? _applications.length 
                    : _applications.where((app) => app.status == filter).length;
                
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getFilterDisplayName(filter),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          if (count > 0) ...[
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withOpacity(0.3) : AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final totalApplications = _applications.length;
    final pendingCount = _applications.where((app) => app.status == 'pending').length;
    final shortlistedCount = _applications.where((app) => app.status == 'shortlisted').length;
    final hiredCount = _applications.where((app) => app.status == 'hired').length;

    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('Total', totalApplications, AppTheme.primaryColor),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.textTertiaryColor.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem('Pending', pendingCount, AppTheme.warningColor),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.textTertiaryColor.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem('Shortlisted', shortlistedCount, AppTheme.infoColor),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.textTertiaryColor.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem('Hired', hiredCount, AppTheme.successColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Title', // This would come from job details
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'School Name', // This would come from school profile
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(application.status),
            ],
          ),
          SizedBox(height: 16),
          
          // Application details
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppTheme.textTertiaryColor,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Applied ${_getTimeAgo(application.appliedAt)}',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
              if (application.reviewedAt != null) ...[
                SizedBox(width: 16),
                Icon(
                  Icons.visibility,
                  color: AppTheme.textTertiaryColor,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Reviewed ${_getTimeAgo(application.reviewedAt!)}',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          
          if (application.reviewNotes != null && application.reviewNotes!.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Notes:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    application.reviewNotes!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: 16),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'View Job',
                  onPressed: () {
                    // Navigate to job details
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  text: 'View Application',
                  onPressed: () {
                    _showApplicationDetails(application);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String displayText;
    
    switch (status) {
      case 'pending':
        color = AppTheme.warningColor;
        displayText = 'Pending';
        break;
      case 'reviewed':
        color = AppTheme.infoColor;
        displayText = 'Reviewed';
        break;
      case 'shortlisted':
        color = AppTheme.primaryColor;
        displayText = 'Shortlisted';
        break;
      case 'rejected':
        color = AppTheme.errorColor;
        displayText = 'Rejected';
        break;
      case 'hired':
        color = AppTheme.successColor;
        displayText = 'Hired';
        break;
      default:
        color = AppTheme.textTertiaryColor;
        displayText = status.toUpperCase();
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppTheme.textTertiaryColor,
          ),
          SizedBox(height: 16),
          Text(
            _selectedFilter == 'all' ? 'No applications yet' : 'No ${_getFilterDisplayName(_selectedFilter).toLowerCase()} applications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _selectedFilter == 'all' 
                ? 'Start applying for jobs to see your applications here'
                : 'Try selecting a different filter',
            style: TextStyle(
              color: AppTheme.textTertiaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (_selectedFilter == 'all') ...[
            SizedBox(height: 24),
            PrimaryButton(
              text: 'Browse Jobs',
              onPressed: () {
                Navigator.pushNamed(context, '/job-search');
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showApplicationDetails(JobApplication application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Application Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  Spacer(),
                  _buildStatusBadge(application.status),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Application info
                    _buildDetailRow('Applied On', _formatDate(application.appliedAt)),
                    if (application.reviewedAt != null)
                      _buildDetailRow('Reviewed On', _formatDate(application.reviewedAt!)),
                    
                    SizedBox(height: 24),
                    
                    // Cover letter
                    Text(
                      'Cover Letter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        application.coverLetter,
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    if (application.reviewNotes != null && application.reviewNotes!.isNotEmpty) ...[
                      SizedBox(height: 24),
                      Text(
                        'Review Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          application.reviewNotes!,
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Close button
            Padding(
              padding: EdgeInsets.all(20),
              child: SecondaryButton(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'pending':
        return 'Pending';
      case 'reviewed':
        return 'Reviewed';
      case 'shortlisted':
        return 'Shortlisted';
      case 'rejected':
        return 'Rejected';
      case 'hired':
        return 'Hired';
      default:
        return filter.toUpperCase();
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
