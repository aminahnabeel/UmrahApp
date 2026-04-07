import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/UserProfileDataModel/user_profile_datamodel.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/UserProfileData/FetchingProfile/fetch_profile.dart';
import 'package:smart_umrah_app/screens/User/UserDashboard/profile_screen.dart';

class UserDashboardController extends GetxController {
  var selectedIndex = 0.obs;
  Rxn<UserProfileDatamodel> currentUser = Rxn<UserProfileDatamodel>();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void changeTab(int index) {
    if (index == 2) {
      Get.to(() => const ProfileDetailScreen());
    } else {
      selectedIndex.value = index;
    }
  }

  loadUser() async {
    final user = await fetchProfile();
    currentUser.value = user;
  }
}