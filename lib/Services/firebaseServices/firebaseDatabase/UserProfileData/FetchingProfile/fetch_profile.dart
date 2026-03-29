import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/Models/UserProfileDataModel/user_profile_datamodel.dart';

Future<UserProfileDatamodel?> fetchProfile() async {
  try {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("No logged in user.");
      return null;
    }

    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();

    if (doc.exists) {
      return UserProfileDatamodel.fromFirebase(doc.data()!);
    }
  } catch (e) {
    print('Error fetching profile: $e');
  }
  return null;
}

Future<List<UserProfileDatamodel>> fetchAllProfiles() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("No profiles found.");
      return [];
    }
    print("Total profiles fetched: ${querySnapshot.docs.length}");

    return querySnapshot.docs
        .map((doc) => UserProfileDatamodel.fromFirebase(doc.data()))
        .toList();
  } catch (e) {
    print('Error fetching all profiles: $e');
    return [];
  }
}
