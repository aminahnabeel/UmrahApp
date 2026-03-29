import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';

Future<TravelAgentProfileModel?> fetchAgentProfile() async {
  try {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("No logged in user.");
      return null;
    }

    final doc = await FirebaseFirestore.instance
        .collection('TravelAgents')
        .doc(userId)
        .get();

    print("Fetched profile for userId: ${doc.exists}");
    if (doc.exists) {
      return TravelAgentProfileModel.fromFirebase(doc.data()!);
    }
  } catch (e) {
    print('Error fetching profile: $e');
  }
  return null;
}

Future<List<TravelAgentProfileModel>> fetchAllAgentProfiles() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('TravelAgents')
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("No profiles found.");
      return [];
    }
    print("Total profiles fetched: ${querySnapshot.docs.length}");

    return querySnapshot.docs
        .map((doc) => TravelAgentProfileModel.fromFirebase(doc.data()))
        .toList();
  } catch (e) {
    print('Error fetching all profiles: $e');
    return [];
  }
}
