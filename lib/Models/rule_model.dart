import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RuleModel {
  final String? id;
  final String ruleText;
  final String category;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPublic;

  RuleModel({
    this.id,
    required this.ruleText,
    required this.category,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isPublic = false,
  });

  /// Convert model to Firestore map
  Map<String, dynamic> toFirebase() {
    return {
      'ruleText': ruleText,
      'category': category,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isPublic': isPublic,
    };
  }

  /// Create model from Firestore document
  factory RuleModel.fromFirebase(Map<String, dynamic> data, String documentId) {
    return RuleModel(
      id: documentId,
      ruleText: data['ruleText'] ?? '',
      category: data['category'] ?? 'General',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isPublic:
          data['isPublic'] ??
          false,
    );
  }

  /// Create a copy with updated fields
  RuleModel copyWith({
    String? id,
    String? ruleText,
    String? category,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
  }) {
    return RuleModel(
      id: id ?? this.id,
      ruleText: ruleText ?? this.ruleText,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}

/// Predefined rule categories
class RuleCategories {
  static const String religious = 'Religious';
  static const String travelDocumentation = 'Travel & Documentation';
  static const String healthSafety = 'Health & Safety';
  static const String general = 'General';

  static List<String> get all => [
    religious,
    travelDocumentation,
    healthSafety,
    general,
  ];

  static IconData getIcon(String category) {
    switch (category) {
      case religious:
        return Icons.mosque;
      case travelDocumentation:
        return Icons.flight_takeoff;
      case healthSafety:
        return Icons.health_and_safety;
      case general:
      default:
        return Icons.info_outline;
    }
  }

  static Color getColor(String category) {
    switch (category) {
      case religious:
        return const Color(0xFF10B981); // Green
      case travelDocumentation:
        return const Color(0xFF3B82F6); // Blue
      case healthSafety:
        return const Color(0xFFF59E0B); // Amber
      case general:
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
