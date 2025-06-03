import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:teacher_connect/screens/auth/login_screen.dart';
import 'package:teacher_connect/screens/auth/signup_screen.dart';
import 'package:teacher_connect/screens/teacher/dashboard_screen.dart';
import 'package:teacher_connect/screens/teacher/profile_setup_screen.dart';
import 'package:teacher_connect/screens/teacher/job_search_screen.dart';
import 'package:teacher_connect/screens/teacher/job_details_screen.dart';
import 'package:teacher_connect/screens/teacher/my_applications_screen.dart';
import 'package:teacher_connect/screens/payment/subscription_screen.dart';
import 'package:teacher_connect/theme/app_theme.dart';
import 'package:teacher_connect/services/auth_service.dart';
import 'package:teacher_connect/models/job_posting.dart';
import 'package:teacher_connect/models/teacher_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TeacherConnectApp());
}

class TeacherConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'Teacher Connect Uganda',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (context) => LoginScreen());
            case '/signup':
              return MaterialPageRoute(builder: (context) => SignupScreen());
            case '/teacher-dashboard':
              return MaterialPageRoute(builder: (context) => TeacherDashboardScreen());
            case '/teacher-profile-setup':
              return MaterialPageRoute(builder: (context) => TeacherProfileSetupScreen());
            case '/teacher-profile-edit':
              final profile = settings.arguments as TeacherProfile?;
              return MaterialPageRoute(
                builder: (context) => TeacherProfileSetupScreen(existingProfile: profile),
              );
            case '/job-search':
              return MaterialPageRoute(builder: (context) => JobSearchScreen());
            case '/job-details':
              final job = settings.arguments as JobPosting;
              return MaterialPageRoute(
                builder: (context) => JobDetailsScreen(job: job),
              );
            case '/my-applications':
              return MaterialPageRoute(builder: (context) => MyApplicationsScreen());
            case '/subscription':
              return MaterialPageRoute(builder: (context) => SubscriptionScreen());
            default:
              return MaterialPageRoute(builder: (context) => LoginScreen());
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          // User is logged in, determine where to navigate based on role
          return FutureBuilder<String>(
            future: authService.getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                );
              }

              String role = roleSnapshot.data ?? '';

              switch (role) {
                case 'teacher':
                  return TeacherDashboardScreen();
                case 'school':
                  // Return SchoolDashboardScreen when created
                  return LoginScreen(); // Temporary
                case 'admin':
                  // Return AdminDashboardScreen when created
                  return LoginScreen(); // Temporary
                default:
                  return LoginScreen();
              }
            },
          );
        } else {
          // User is not logged in
          return LoginScreen();
        }
      },
    );
  }
}