import 'package:flutter/material.dart';
import 'package:smart_umrah_app/routes/routes.dart';

List<Map<String, dynamic>> get adminFeatures => [
  {
    'title': 'Update Laws & Regulations',
    'icon': Icons.gavel,
    'description': 'Manage rules for Umrah',
    'route': AppRoutes.adminrulesandregulation,
  },
  {
    'title': 'Notifications',
    'icon': Icons.notifications,
    'description': 'View & send alerts',
    'route': AppRoutes.unverfiedagentnotifications,
  },
  {
    'title': 'Manage Travel Agents',
    'icon': Icons.group,
    'description': 'add, update, delete',
    'route': AppRoutes.adminmanagetravelagent,
  },
  {
    'title': 'Manage Pilgrims',
    'icon': Icons.person,
    'description': 'Approve, add, update, delete agents',
    'route': AppRoutes.adminmanagepilgram,
  },
];
