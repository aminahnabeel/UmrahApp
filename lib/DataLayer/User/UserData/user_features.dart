import 'package:flutter/material.dart';
import 'package:smart_umrah_app/routes/routes.dart';

final List<Map<String, dynamic>> userFeatures = [
  {
    'title': 'Umrah Guide',
    'description': 'Audio, Videos, Duas',
    'icon': Icons.menu_book,
    'route': AppRoutes.umrahguide,
  },
  {
    'title': 'Travel Checklist',
    'description': 'Packing List + Notes',
    'icon': Icons.checklist,
    'route': AppRoutes.travelchecklist,
  },
  {
    'title': 'Rules & Regulations',
    'description': 'Visa, Entry, Laws',
    'icon': Icons.gavel,
    'route': AppRoutes.umrahrules,
  },
  {
    'title': 'Manage Documents',
    'description': 'Passport, Visas',
    'icon': Icons.folder_shared,
    'route': AppRoutes.managedoc,
  },
  {
    'title': 'Transportation Routes',
    'description': 'Bus Schedules',
    'icon': Icons.directions_bus,
    'route': AppRoutes.transportroutes,
  },
  {
    'title': 'Umrah Journal',
    'description': 'Create & Save Memories',
    'icon': Icons.book,
    'route': AppRoutes.umrahjournal,
  },
  {
    'title': 'Track Expenses',
    'description': "Manage Expense",
    'icon': Icons.paid,
    'route': AppRoutes.trackexpenses,
  },
  {
    'title': 'Tawaf & Sai Counter',
    'description': 'Keep track of your rounds',
    'icon': Icons.loop,
    'route': AppRoutes.tawafsaicounter,
  },
  {
    'title': 'View Places',
    'description': 'Hotels, Restaurants, Markets, Ziarats',
    'icon': Icons.place,
    'route': AppRoutes.viewplaces,
  },
  {
    'title': 'Notifications',
    'description': 'View important alerts',
    'icon': Icons.notifications,
    'route': AppRoutes.usernotification,
  },
  {
    'title': 'Offline Guide Access',
    'description': 'Access guide without internet',
    'icon': Icons.wifi_off,
    'route': AppRoutes.userofflineaccess,
  },
  {
    'title': 'View Travel Agent',
    'description': 'Contact your assigned agent/group',
    'icon': Icons.person_pin,
    'route': AppRoutes.viewtravelagent,
  },

  {
    'title': 'InappMessaging',
    'description': 'Contact your assigned agent/group',
    'icon': Icons.person_pin,
    'route': AppRoutes.allChats,
  },
];
