import 'package:firebase_auth/firebase_auth.dart';

String? getID() {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid; // returns null if no user is logged in
}
