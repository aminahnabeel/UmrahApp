import 'package:flutter/material.dart';
import 'package:smart_umrah_app/routes/routes.dart';

List<Map<String, dynamic>> get agentFeatures => [
  {
    'title': 'Generate Schedule',
    'icon': Icons.calendar_month,
    'description': 'Create Umrah itineraries',
    'route': AppRoutes.agentscedule,
  },

  {
    'title': 'In-app Messaging',
    'icon': Icons.message,
    'description': 'Communicate with pilgrims',
    'route': AppRoutes.agentviewAllchats,
  },

  {
    'title': 'Pilgram Requests',
    'icon': Icons.person_add,
    'description': 'Accept or reject pilgrim requests',
    'route': AppRoutes.agentpilgramrequests,
  },

  {
    'title': 'Manage Rules',
    'icon': Icons.rule,
    'description': 'Add, edit & delete rules',
    'route': AppRoutes.agentrules,
  },

  {
    'title': 'View Groups',
    'icon': Icons.group,
    'description': 'See your approved members',
    'route': AppRoutes.agentviewgroups,
  },
];
