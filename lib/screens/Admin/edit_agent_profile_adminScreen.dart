import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/AgentData/agent_data.dart';
import 'package:smart_umrah_app/widgets/customButton.dart';
import 'package:smart_umrah_app/widgets/customtextfield.dart';

class EditAgentProfileAdminScreen extends StatefulWidget {
  final String agentId;
  final TravelAgentProfileModel agentData;

  const EditAgentProfileAdminScreen({
    super.key,
    required this.agentId,
    required this.agentData,
  });

  @override
  State<EditAgentProfileAdminScreen> createState() =>
      _EditAgentProfileAdminScreenState();
}

class _EditAgentProfileAdminScreenState
    extends State<EditAgentProfileAdminScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController name;
  late TextEditingController agencyName;
  late TextEditingController passport;
  late TextEditingController address;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.agentData.name);
    agencyName = TextEditingController(text: widget.agentData.agencyName);
    passport = TextEditingController(text: widget.agentData.passportNumber);
    address = TextEditingController(text: widget.agentData.permanentAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Agent Profile")),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              customTextField("Name", controller: name, labelText: "Name"),
              const SizedBox(height: 15),

              customTextField(
                "Agency Name",
                controller: agencyName,
                labelText: "Agency Name",
              ),
              const SizedBox(height: 15),

              customTextField(
                "Passport Number",
                controller: passport,
                labelText: "Passport Number",
              ),
              const SizedBox(height: 15),

              customTextField(
                "Permanent Address",
                controller: address,
                labelText: "Address",
              ),
              const SizedBox(height: 25),

              CustomButton(
                text: "Update",
                onPressed: () async {
                  final updated = TravelAgentProfileModel(
                    id: widget.agentId,
                    name: name.text.trim(),
                    agencyName: agencyName.text.trim(),
                    passportNumber: passport.text.trim(),
                    permanentAddress: address.text.trim(),
                    email: widget.agentData.email,
                    password: widget.agentData.password,
                    dateOfBirth: widget.agentData.dateOfBirth,
                    gender: widget.agentData.gender,
                    profileImageUrl: widget.agentData.profileImageUrl,
                    isVerified: widget.agentData.isVerified,
                  );

                  await AgentProfileDataCollection().database
                      .collection("TravelAgents")
                      .doc(widget.agentId)
                      .update(updated.toFirebase());

                  Get.back();
                  Get.snackbar(
                    "Updated",
                    "Agent updated successfully",
                    backgroundColor: Colors.green.withOpacity(0.2),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
