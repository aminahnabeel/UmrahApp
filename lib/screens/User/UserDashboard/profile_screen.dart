import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/UserProfileDataModel/user_profile_datamodel.dart';
import 'package:smart_umrah_app/Services/firebaseServices/AuthServices/logout.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/UserProfileData/newUser_profile_data_collection.dart';
import 'package:smart_umrah_app/screens/User/UserDashboard/user_dashboard_controller.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color scaffoldBgColor = Color(0xFFF4F7FA);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserDashboardController>();

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text("My Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final user = controller.currentUser.value;
        final userName = user?.name ?? "";
        final firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // --- Header ---
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
                ),
                padding: const EdgeInsets.only(bottom: 40, top: 10),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(firstLetter, style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: primaryBlue)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(user?.name ?? "Loading...", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(user?.email ?? "", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Editable Info List ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildEditTile("Full Name", user?.name ?? "N/A", Icons.person_outline, 
                        () => _showEditDialog(context, "name", user?.name ?? "", controller)),
                    
                    _buildEditTile("Gender", user?.gender ?? "N/A", Icons.wc_outlined, 
                        () => _showGenderDialog(context, user?.gender ?? "Male", controller)),
                    
                    _buildEditTile("Date of Birth", user?.dateOfBirth ?? "N/A", Icons.calendar_today_outlined, 
                        () => _showDatePicker(context, controller)),
                    
                    _buildEditTile("Passport Number", user?.passportNumber ?? "N/A", Icons.badge_outlined, 
                        () => _showEditDialog(context, "passport", user?.passportNumber ?? "", controller)),
                    
                    _buildEditTile("Address", user?.permanentAddress ?? "N/A", Icons.location_on_outlined, 
                        () => _showEditDialog(context, "address", user?.permanentAddress ?? "", controller)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: OutlinedButton(
                  onPressed: () async => await logoutUser(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("SIGN OUT", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEditTile(String label, String value, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: primaryBlue),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        trailing: const Icon(Icons.edit_note, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // --- 1. Text Field Edit Dialog ---
  void _showEditDialog(BuildContext context, String field, String currentValue, UserDashboardController controller) {
    final textController = TextEditingController(text: currentValue);
    Get.defaultDialog(
      title: "Update $field",
      content: TextField(controller: textController, decoration: const InputDecoration(border: OutlineInputBorder())),
      textConfirm: "SAVE NOW",
      onConfirm: () => _updateUserData(controller, field, textController.text.trim()),
    );
  }

  // --- 2. Gender Dropdown Dialog ---
  void _showGenderDialog(BuildContext context, String currentGender, UserDashboardController controller) {
    String tempGender = currentGender;
    Get.defaultDialog(
      title: "Select Gender",
      content: StatefulBuilder(builder: (context, setState) {
        return DropdownButton<String>(
          value: ["Male", "Female", "Other"].contains(tempGender) ? tempGender : "Male",
          isExpanded: true,
          items: ["Male", "Female", "Other"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => tempGender = newValue!),
        );
      }),
      textConfirm: "SAVE NOW",
      onConfirm: () => _updateUserData(controller, "gender", tempGender),
    );
  }

  // --- 3. Date Picker ---
  void _showDatePicker(BuildContext context, UserDashboardController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      String formattedDate = "${picked.year}-${picked.month}-${picked.day}";
      _updateUserData(controller, "dob", formattedDate);
    }
  }

  // --- Core Update Logic ---
  Future<void> _updateUserData(UserDashboardController controller, String field, String newValue) async {
    final currentUser = controller.currentUser.value;
    if (currentUser == null) return;

    UserProfileDatamodel updatedUser = currentUser.copyWith(
      name: field == "name" ? newValue : null,
      gender: field == "gender" ? newValue : null,
      dateOfBirth: field == "dob" ? newValue : null,
      passportNumber: field == "passport" ? newValue : null,
      permanentAddress: field == "address" ? newValue : null,
    );

    // Save to Firebase
    await NewProfileDataCollection().saveUserProfileData(updatedUser);
    
    // Update Local UI
    controller.currentUser.value = updatedUser;

    if (Get.isDialogOpen!) Get.back(); // Remove Popup
    Get.snackbar("Success", "${field.capitalizeFirst} Updated", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
  }
}