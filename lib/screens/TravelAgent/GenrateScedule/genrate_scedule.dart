import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/AgentControllers/genrate_scedule_controller.dart';
import 'package:smart_umrah_app/screens/TravelAgent/GenrateScedule/allScedule.dart';
import 'package:smart_umrah_app/widgets/customtextfield.dart';

class GenerateSchedulePage extends StatelessWidget {
  GenerateSchedulePage({super.key});

  final controller = Get.put(GenerateScheduleController());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Generate Umrah Schedule",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.white),
            onPressed: () => Get.to(() => const ViewAllSchedules()),
          ),
        ],
      ),

      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00695C),   // Teal shade
                  Color(0xFF26A69A),   // Light teal
                  Color(0xFFB2DFDB),   // Very soft teal
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Positioned(
            bottom: -40,
            right: -30,
            child: Opacity(
              opacity: 0.12,
              child: Image(
                image: AssetImage("assets/masjid.png"),
                height: height * 0.45,
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
            child: Column(
              children: [
                Text(
                  "Create Your\nUmrah Itinerary",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: height * 0.034,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 25),

                _glassCard(width),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white30, width: 1),
      ),

      child: Column(
        children: [
          customTextField(
            "Departure City",
            controller: controller.departureCityController,
            prefixIcon: Icon(Icons.location_on, color: Colors.teal),
            labelText: "Enter city",
          ),

          const SizedBox(height: 15),

          _datePickerField(
            controller.departureDateController,
            icon: Icons.flight_takeoff,
            title: "Departure Date",
          ),

          const SizedBox(height: 15),

          _datePickerField(
            controller.returnDateController,
            icon: Icons.flight_land,
            title: "Return Date",
          ),

          const SizedBox(height: 15),

          customTextField(
            "Number of Pilgrims",
            keyboardType: TextInputType.number,
            controller: controller.pilgrimsCountController,
            prefixIcon: Icon(Icons.group, color: Colors.teal),
            labelText: "Enter count",
          ),

          const SizedBox(height: 15),

          customTextField(
            "Hotel Preference",
            controller: controller.hotelController,
            prefixIcon: Icon(Icons.hotel, color: Colors.teal),
            labelText: "Enter hotel",
          ),

          const SizedBox(height: 25),

          Obx(
            () => controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : _submitButton(),
          ),
        ],
      ),
    );
  }

  Widget _datePickerField(
    TextEditingController c, {
    required IconData icon,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),

        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: Get.context!,
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );

            if (picked != null) {
              c.text = "${picked.day}-${picked.month}-${picked.year}";
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    c.text.isEmpty ? "Select date" : c.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () => controller.saveSchedule(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00897B),  // Teal
              Color(0xFF26A69A),  // Light teal
            ],
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_mode_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Generate Schedule",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
