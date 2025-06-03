import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Subscription plans
  final Map<String, dynamic> subscriptionPlans = {
    'basic': {
      'id': 'basic',
      'name': 'Basic Plan',
      'price': 10000, // UGX
      'duration': 30, // days
      'features': [
        'Profile visibility to schools',
        'Basic profile customization',
        'Email notifications',
      ],
    },
    'premium': {
      'id': 'premium',
      'name': 'Premium Plan',
      'price': 25000, // UGX
      'duration': 30, // days
      'features': [
        'Priority listing in search results',
        'Advanced profile customization',
        'Direct messaging with schools',
        'Job application tracking',
        'Resume/CV builder',
      ],
    },
    'annual': {
      'id': 'annual',
      'name': 'Annual Plan',
      'price': 200000, // UGX
      'duration': 365, // days
      'features': [
        'All Premium features',
        'Featured profile badge',
        'Personalized job recommendations',
        'Interview preparation resources',
        'Priority customer support',
      ],
    },
  };

  // Process subscription payment
  Future<Map<String, dynamic>> processSubscription(String planId, String phoneNumber) async {
    try {
      String userId = _auth.currentUser!.uid;
      
      // Get plan details
      final plan = subscriptionPlans[planId];
      if (plan == null) {
        throw Exception('Invalid subscription plan');
      }
      
      // In a real app, you would integrate with a payment gateway here
      // For this example, we'll simulate a successful payment
      
      // For Mobile Money integration, you would make an API call to the payment provider
      // Example with MTN Mobile Money (simulated):
      /*
      final response = await http.post(
        Uri.parse('https://api.mtn.com/collection/v1/requesttopay'),
        headers: {
          'Authorization': '