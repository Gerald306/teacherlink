import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teacher_connect/models/teacher_profile.dart';
import 'package:teacher_connect/services/teacher_service.dart';
import 'package:teacher_connect/services/auth_service.dart';
import 'package:teacher_connect/theme/app_theme.dart';
import 'package:teacher_connect/widgets/custom_button.dart';
import 'package:teacher_connect/widgets/custom_text_field.dart';
import 'dart:io';

class TeacherProfileSetupScreen extends StatefulWidget {
  final TeacherProfile? existingProfile;
  
  const TeacherProfileSetupScreen({Key? key, this.existingProfile}) : super(key: key);

  @override
  _TeacherProfileSetupScreenState createState() => _TeacherProfileSetupScreenState();
}

class _TeacherProfileSetupScreenState extends State<TeacherProfileSetupScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _teacherService = TeacherService();
  final _authService = AuthService();
  final _imagePicker = ImagePicker();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _currentPositionController = TextEditingController();
  final _expectedSalaryController = TextEditingController();
  
  // State variables
  File? _profileImage;
  String? _profileImageUrl;
  List<String> _selectedSubjects = [];
  List<String> _selectedSkills = [];
  List<String> _selectedLanguages = ['English'];
  List<Qualification> _qualifications = [];
  int _yearsOfExperience = 0;
  String _preferredJobType = 'full-time';
  bool _isLoading = false;
  int _currentStep = 0;
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Predefined options
  final List<String> _availableSubjects = [
    'Mathematics', 'English', 'Science', 'Physics', 'Chemistry', 'Biology',
    'History', 'Geography', 'Literature', 'Computer Science', 'Art',
    'Music', 'Physical Education', 'Religious Education', 'Economics',
    'Business Studies', 'Agriculture', 'Technical Drawing'
  ];
  
  final List<String> _availableSkills = [
    'Classroom Management', 'Curriculum Development', 'Student Assessment',
    'Technology Integration', 'Special Needs Education', 'Multilingual Teaching',
    'Research', 'Leadership', 'Mentoring', 'Public Speaking', 'Writing',
    'Project Management', 'Team Collaboration', 'Creative Teaching Methods'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    
    if (widget.existingProfile != null) {
      _populateExistingData();
    }
  }

  void _populateExistingData() {
    final profile = widget.existingProfile!;
    _fullNameController.text = profile.fullName;
    _phoneController.text = profile.phone;
    _locationController.text = profile.location;
    _bioController.text = profile.bio ?? '';
    _currentPositionController.text = profile.currentPosition ?? '';
    _expectedSalaryController.text = profile.expectedSalary?.toString() ?? '';
    _profileImageUrl = profile.profileImageUrl;
    _selectedSubjects = List.from(profile.subjects);
    _selectedSkills = List.from(profile.skills);
    _selectedLanguages = List.from(profile.languages);
    _qualifications = List.from(profile.qualifications);
    _yearsOfExperience = profile.yearsOfExperience;
    _preferredJobType = profile.preferredJobType ?? 'full-time';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _currentPositionController.dispose();
    _expectedSalaryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one subject'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String? profileImageUrl = _profileImageUrl;
      
      // Upload profile image if selected
      if (_profileImage != null) {
        profileImageUrl = await _teacherService.uploadProfileImage(_profileImage!, user.uid);
      }

      final profile = TeacherProfile(
        id: widget.existingProfile?.id ?? '',
        userId: user.uid,
        fullName: _fullNameController.text.trim(),
        email: user.email ?? '',
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        profileImageUrl: profileImageUrl,
        bio: _bioController.text.trim(),
        qualifications: _qualifications,
        subjects: _selectedSubjects,
        skills: _selectedSkills,
        languages: _selectedLanguages,
        yearsOfExperience: _yearsOfExperience,
        currentPosition: _currentPositionController.text.trim(),
        preferredJobType: _preferredJobType,
        expectedSalary: double.tryParse(_expectedSalaryController.text),
        createdAt: widget.existingProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _teacherService.saveTeacherProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        Navigator.pushReplacementNamed(context, '/teacher-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.existingProfile != null ? 'Edit Profile' : 'Setup Your Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep ? AppTheme.primaryColor : AppTheme.textTertiaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            Expanded(
              child: PageView(
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildBasicInfoStep(),
                  _buildSubjectsSkillsStep(),
                  _buildExperienceStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            
            // Navigation buttons
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: SecondaryButton(
                        text: 'Previous',
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                      ),
                    ),
                  if (_currentStep > 0) SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: _currentStep == 3 ? 'Save Profile' : 'Next',
                      onPressed: _currentStep == 3 ? _saveProfile : () {
                        setState(() {
                          _currentStep++;
                        });
                      },
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Let\'s start with your basic details',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),
            
            // Profile Image
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: _profileImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(58),
                          child: Image.file(
                            _profileImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _profileImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(58),
                              child: Image.network(
                                _profileImageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: AppTheme.primaryColor,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),
            SizedBox(height: 32),
            
            CustomTextField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            CustomTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'Enter your location (City, District)',
              prefixIcon: Icons.location_on_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your location';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            CustomTextField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Tell us about yourself...',
              prefixIcon: Icons.info_outlined,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsSkillsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subjects & Skills',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select the subjects you teach and your skills',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 32),
          
          // Subjects
          Text(
            'Subjects I Teach',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSubjects.map((subject) {
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
                    color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiaryColor.withOpacity(0.3),
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
          SizedBox(height: 32),
          
          // Skills
          Text(
            'Skills & Expertise',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSkills.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSkills.remove(skill);
                    } else {
                      _selectedSkills.add(skill);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.secondaryColor : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.secondaryColor : AppTheme.textTertiaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    skill,
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
    );
  }

  Widget _buildExperienceStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience & Preferences',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tell us about your experience and job preferences',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 32),
          
          // Years of Experience
          Text(
            'Years of Experience',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.textTertiaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.work_outline, color: AppTheme.primaryColor),
                SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _yearsOfExperience.toDouble(),
                    min: 0,
                    max: 30,
                    divisions: 30,
                    activeColor: AppTheme.primaryColor,
                    label: '$_yearsOfExperience years',
                    onChanged: (value) {
                      setState(() {
                        _yearsOfExperience = value.round();
                      });
                    },
                  ),
                ),
                Text(
                  '$_yearsOfExperience years',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          CustomTextField(
            controller: _currentPositionController,
            label: 'Current Position',
            hint: 'e.g., Mathematics Teacher at ABC School',
            prefixIcon: Icons.badge_outlined,
          ),
          SizedBox(height: 16),
          
          // Preferred Job Type
          Text(
            'Preferred Job Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildJobTypeCard('full-time', 'Full Time'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildJobTypeCard('part-time', 'Part Time'),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildJobTypeCard('contract', 'Contract'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildJobTypeCard('temporary', 'Temporary'),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          CustomTextField(
            controller: _expectedSalaryController,
            label: 'Expected Salary (UGX)',
            hint: 'Enter your expected monthly salary',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildJobTypeCard(String type, String title) {
    final isSelected = _preferredJobType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _preferredJobType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiaryColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Profile',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please review your information before saving',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 32),
          
          // Profile Summary Card
          Container(
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
              children: [
                // Profile Image and Name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : null,
                      child: _profileImage == null && _profileImageUrl == null
                          ? Icon(Icons.person, color: AppTheme.primaryColor, size: 30)
                          : null,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fullNameController.text,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          Text(
                            _locationController.text,
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                // Summary Info
                _buildSummaryRow('Phone', _phoneController.text),
                _buildSummaryRow('Experience', '$_yearsOfExperience years'),
                _buildSummaryRow('Job Type', _preferredJobType.replaceAll('-', ' ').toUpperCase()),
                _buildSummaryRow('Subjects', _selectedSubjects.take(3).join(', ') + 
                    (_selectedSubjects.length > 3 ? ' +${_selectedSubjects.length - 3} more' : '')),
                _buildSummaryRow('Skills', _selectedSkills.take(3).join(', ') + 
                    (_selectedSkills.length > 3 ? ' +${_selectedSkills.length - 3} more' : '')),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          // Important Note
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.infoColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.infoColor,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your profile will be reviewed by our team before being visible to schools. This usually takes 24-48 hours.',
                    style: TextStyle(
                      color: AppTheme.infoColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
}
