import 'package:flutter/material.dart';
import 'package:teacher_connect/models/job_posting.dart';
import 'package:teacher_connect/models/school_profile.dart';
import 'package:teacher_connect/services/job_service.dart';
import 'package:teacher_connect/theme/app_theme.dart';
import 'package:teacher_connect/widgets/custom_button.dart';
import 'package:teacher_connect/widgets/custom_text_field.dart';

class JobSearchScreen extends StatefulWidget {
  @override
  _JobSearchScreenState createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> with TickerProviderStateMixin {
  final _jobService = JobService();
  final _searchController = TextEditingController();
  
  List<JobPosting> _jobs = [];
  List<JobPosting> _filteredJobs = [];
  bool _isLoading = true;
  String _selectedJobType = 'all';
  String _selectedLocation = 'all';
  List<String> _selectedSubjects = [];
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<String> _jobTypes = ['all', 'full-time', 'part-time', 'contract', 'temporary'];
  final List<String> _locations = ['all', 'Kampala', 'Entebbe', 'Jinja', 'Mbarara', 'Gulu', 'Lira'];
  final List<String> _subjects = [
    'Mathematics', 'English', 'Science', 'Physics', 'Chemistry', 'Biology',
    'History', 'Geography', 'Literature', 'Computer Science'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _loadJobs();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    try {
      final jobs = await _jobService.getActiveJobs();
      setState(() {
        _jobs = jobs;
        _filteredJobs = jobs;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading jobs: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _filterJobs() {
    setState(() {
      _filteredJobs = _jobs.where((job) {
        // Search text filter
        if (_searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          if (!job.title.toLowerCase().contains(searchText) &&
              !job.description.toLowerCase().contains(searchText)) {
            return false;
          }
        }
        
        // Job type filter
        if (_selectedJobType != 'all' && job.jobType != _selectedJobType) {
          return false;
        }
        
        // Location filter
        if (_selectedLocation != 'all' && !job.location.contains(_selectedLocation)) {
          return false;
        }
        
        // Subject filter
        if (_selectedSubjects.isNotEmpty) {
          bool hasMatchingSubject = false;
          for (String subject in _selectedSubjects) {
            if (job.requiredSubjects.contains(subject)) {
              hasMatchingSubject = true;
              break;
            }
          }
          if (!hasMatchingSubject) return false;
        }
        
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Find Jobs'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
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
                  // Search and filter section
                  Container(
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
                      children: [
                        CustomTextField(
                          controller: _searchController,
                          label: 'Search Jobs',
                          hint: 'Search by title or description...',
                          prefixIcon: Icons.search,
                          onChanged: (value) => _filterJobs(),
                        ),
                        SizedBox(height: 16),
                        
                        // Quick filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildQuickFilter('All Jobs', _selectedJobType == 'all', () {
                                setState(() {
                                  _selectedJobType = 'all';
                                  _filterJobs();
                                });
                              }),
                              SizedBox(width: 8),
                              _buildQuickFilter('Full Time', _selectedJobType == 'full-time', () {
                                setState(() {
                                  _selectedJobType = 'full-time';
                                  _filterJobs();
                                });
                              }),
                              SizedBox(width: 8),
                              _buildQuickFilter('Part Time', _selectedJobType == 'part-time', () {
                                setState(() {
                                  _selectedJobType = 'part-time';
                                  _filterJobs();
                                });
                              }),
                              SizedBox(width: 8),
                              _buildQuickFilter('Contract', _selectedJobType == 'contract', () {
                                setState(() {
                                  _selectedJobType = 'contract';
                                  _filterJobs();
                                });
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Results header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          '${_filteredJobs.length} jobs found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: _showSortOptions,
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Sort',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Jobs list
                  Expanded(
                    child: _filteredJobs.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _filteredJobs.length,
                            itemBuilder: (context, index) {
                              return _buildJobCard(_filteredJobs[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickFilter(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiaryColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(JobPosting job) {
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
                      job.title,
                      style: TextStyle(
                        fontSize: 18,
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
              if (job.isPremium)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'FEATURED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          
          // Job details
          Row(
            children: [
              _buildJobDetail(Icons.location_on_outlined, job.location),
              SizedBox(width: 16),
              _buildJobDetail(Icons.work_outline, job.jobType.replaceAll('-', ' ').toUpperCase()),
            ],
          ),
          SizedBox(height: 12),
          
          if (job.salaryMin != null && job.salaryMax != null)
            Row(
              children: [
                _buildJobDetail(
                  Icons.attach_money,
                  'UGX ${job.salaryMin!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} - ${job.salaryMax!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                ),
              ],
            ),
          SizedBox(height: 16),
          
          // Subjects
          if (job.requiredSubjects.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.requiredSubjects.take(3).map((subject) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    subject,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          SizedBox(height: 16),
          
          // Description preview
          Text(
            job.description,
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16),
          
          // Footer
          Row(
            children: [
              Text(
                'Posted ${_getTimeAgo(job.createdAt)}',
                style: TextStyle(
                  color: AppTheme.textTertiaryColor,
                  fontSize: 12,
                ),
              ),
              Spacer(),
              SecondaryButton(
                text: 'View Details',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/job-details',
                    arguments: job,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppTheme.textTertiaryColor,
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.textTertiaryColor,
          ),
          SizedBox(height: 16),
          Text(
            'No jobs found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(
              color: AppTheme.textTertiaryColor,
            ),
          ),
          SizedBox(height: 24),
          SecondaryButton(
            text: 'Clear Filters',
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedJobType = 'all';
                _selectedLocation = 'all';
                _selectedSubjects.clear();
                _filterJobs();
              });
            },
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
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
                    'Filter Jobs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedJobType = 'all';
                        _selectedLocation = 'all';
                        _selectedSubjects.clear();
                      });
                      _filterJobs();
                      Navigator.pop(context);
                    },
                    child: Text('Clear All'),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Type Filter
                    Text(
                      'Job Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _jobTypes.map((type) {
                        final isSelected = _selectedJobType == type;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedJobType = type;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              type == 'all' ? 'All Types' : type.replaceAll('-', ' ').toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24),
                    
                    // Location Filter
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _locations.map((location) {
                        final isSelected = _selectedLocation == location;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLocation = location;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              location == 'all' ? 'All Locations' : location,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24),
                    
                    // Subject Filter
                    Text(
                      'Subjects',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _subjects.map((subject) {
                        final isSelected = _selectedSubjects.contains(subject);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSubjects.remove(subject);
                              } else {
                                _selectedSubjects.add(subject);
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.secondaryColor : AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppTheme.secondaryColor : AppTheme.textTertiaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              subject,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Apply button
            Padding(
              padding: EdgeInsets.all(20),
              child: PrimaryButton(
                text: 'Apply Filters',
                onPressed: () {
                  _filterJobs();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildSortOption('Most Recent', () {
                    setState(() {
                      _filteredJobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    });
                    Navigator.pop(context);
                  }),
                  _buildSortOption('Salary: High to Low', () {
                    setState(() {
                      _filteredJobs.sort((a, b) => (b.salaryMax ?? 0).compareTo(a.salaryMax ?? 0));
                    });
                    Navigator.pop(context);
                  }),
                  _buildSortOption('Salary: Low to High', () {
                    setState(() {
                      _filteredJobs.sort((a, b) => (a.salaryMin ?? 0).compareTo(b.salaryMin ?? 0));
                    });
                    Navigator.pop(context);
                  }),
                  _buildSortOption('Application Deadline', () {
                    setState(() {
                      _filteredJobs.sort((a, b) => a.applicationDeadline.compareTo(b.applicationDeadline));
                    });
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textTertiaryColor,
      ),
    );
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
}
