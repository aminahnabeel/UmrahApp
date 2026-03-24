import 'package:get/get.dart';
import 'package:smart_umrah_app/screens/Admin/admin_dashboard.dart';
import 'package:smart_umrah_app/screens/Admin/manage_pilgram_adminSide.dart';
import 'package:smart_umrah_app/screens/Admin/manage_travel_agent.dart';
import 'package:smart_umrah_app/screens/Admin/rules&regulation.dart';
import 'package:smart_umrah_app/screens/Admin/verify_agent_notification_screen.dart';
import 'package:smart_umrah_app/screens/TravelAgent/AgentChatScreens/ViewAllChatsScreen.dart';
import 'package:smart_umrah_app/screens/TravelAgent/auth_pages/agentSignIn.dart';
import 'package:smart_umrah_app/screens/TravelAgent/auth_pages/agentSignupScreen.dart';
import 'package:smart_umrah_app/screens/TravelAgent/GenrateScedule/genrate_scedule.dart';
import 'package:smart_umrah_app/screens/TravelAgent/pilgramsrequest.dart';
import 'package:smart_umrah_app/screens/TravelAgent/travel_agent_dashboard.dart';
import 'package:smart_umrah_app/screens/User/AllChatsScreen.dart';
import 'package:smart_umrah_app/screens/User/UserDashboard/user_dashboard.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/TawafSaiCounter/tawaf_sai_counter.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/manage_docs.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/notification.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/offline_guide_access.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/rule.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/track_expenses.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/transport_routes.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/ViewPlace/view_places.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/view_travel_agent.dart';
import 'package:smart_umrah_app/screens/User/auth_pages/forgot_password_screen.dart';
import 'package:smart_umrah_app/screens/User/auth_pages/userSignIn.dart';
import 'package:smart_umrah_app/screens/User/auth_pages/userSignupScreen.dart';
import 'package:smart_umrah_app/screens/landing_screen.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/travel_checklist_screen.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/UmrahGuide/umrah_guide_screen.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/umrah_journal_screen.dart';

class AppRoutes {
  // User Side Routes
  static const String landingscreen = '/';
  static const String userregister = '/register';
  static const String usersignin = '/usersignin';
  static const String userdashboard = '/userdashboard';
  static const String forgotpassword = '/forgotpassword';

  // Admin Side Routes
  static const String admindashboard = '/admindashboard';
  static const String adminrulesandregulation = '/adminrulesandregulation';
  static const String adminmanagetravelagent = '/adminmanagetravelagent';
  static const String unverfiedagentnotifications =
      '/unverfiedagentnotifications';

  static const String adminmanagepilgram = '/adminmanagepilgram';

  // User Features Routes
  static const String umrahguide = '/umrahguide';
  static const String travelchecklist = '/travelchecklist';
  static const String umrahjournal = '/umrahjournal';
  static const String umrahrules = '/rules';
  static const String managedoc = '/managedocs';
  static const String transportroutes = '/transportroutes';
  static const String trackexpenses = '/trackexpenses';
  static const String tawafsaicounter = '/tawafsaicounter';
  static const String viewplaces = '/viewplaces';
  static const String usernotification = '/usersidenotification';
  static const String userofflineaccess = '/userofflineaccess';
  static const String viewtravelagent = '/view_travel_agent';

  // Travel Agent Side Routes
  static const String agentregister = '/agentregister';
  static const String agentsignin = '/agentsignin';
  static const String agentdashboard = '/agentdashboard';
  static const String agentscedule = '/agentscedule';
  static const String agentviewAllchats = '/agentviewAllchats';
  static const String agentpilgramrequests = '/agentpilgramrequests';
  // Chat Route
  static const String allChats = '/allchats';
  final getpags = [
    // User Side Pages
    GetPage(name: landingscreen, page: () => LandingScreen()),
    GetPage(name: usersignin, page: () => UserSignInScreen()),
    GetPage(name: userregister, page: () => UserSignUpScreen()),
    GetPage(name: userdashboard, page: () => UserDashboard()),
    GetPage(name: forgotpassword, page: () => ForgotPasswordScreen()),

    // User Features Pages
    GetPage(name: umrahguide, page: () => UmrahGuideScreen()),
    GetPage(name: travelchecklist, page: () => TravelChecklistScreen()),
    GetPage(name: umrahjournal, page: () => UmrahJournalScreen()),
    GetPage(name: umrahrules, page: () => UmrahRulesScreen()),
    GetPage(name: managedoc, page: () => ManageDocScreen()),
    GetPage(name: transportroutes, page: () => TransportRoutes()),
    GetPage(name: trackexpenses, page: () => TrackExpenses()),
    GetPage(name: tawafsaicounter, page: () => TawafSaiCounter()),
    GetPage(name: viewplaces, page: () => ViewPlaceScreen()),
    GetPage(name: usernotification, page: () => NotificationScreen()),
    GetPage(name: userofflineaccess, page: () => OfflineGuideAccess()),
    GetPage(name: viewtravelagent, page: () => ViewTravelAgent()),

    // Travel Agent Side Pages
    GetPage(name: agentregister, page: () => TravelAgentSignUpScreen()),
    GetPage(name: agentsignin, page: () => AgentSignInScreen()),
    GetPage(name: agentdashboard, page: () => TravelAgentDashboardScreen()),
    GetPage(name: agentscedule, page: () => GenerateSchedulePage()),
    GetPage(name: agentviewAllchats, page: () => AgentViewAllChatsScreen()),
    GetPage(name: agentpilgramrequests, page: () => PilgramRequestsScreen()),

    // Chat Page
    GetPage(name: allChats, page: () => AllChatsScreen()),

    // Admin Side Pages
    GetPage(name: admindashboard, page: () => AdminDashboardScreen()),
    GetPage(name: adminrulesandregulation, page: () => UpdateRulesScreen()),
    GetPage(
      name: adminmanagetravelagent,
      page: () => AdminManageAgentsScreen(),
    ),
    GetPage(
      name: unverfiedagentnotifications,
      page: () => AdminNotificationsUnverifiedAgents(),
    ),
    GetPage(name: adminmanagepilgram, page: () => AdminManagePilgrimsScreen()),
  ];
}
