import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing an approved user in a Travel Agent's approved users group
class ApprovedUserModel {
  final String userId;
  final String agentId;
  final DateTime approvedAt;
  final String userName;
  final String userEmail;
  final String status;
  final DateTime createdAt;

  ApprovedUserModel({
    required this.userId,
    required this.agentId,
    required this.approvedAt,
    required this.userName,
    required this.userEmail,
    this.status = 'approved',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? approvedAt;

  /// Convert model to Firestore map
  Map<String, dynamic> toFirebase() {
    return {
      'userId': userId,
      'agentId': agentId,
      'approvedAt': Timestamp.fromDate(approvedAt),
      'userName': userName,
      'userEmail': userEmail,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create model from Firestore document
  factory ApprovedUserModel.fromFirebase(Map<String, dynamic> data) {
    return ApprovedUserModel(
      userId: data['userId'] ?? '',
      agentId: data['agentId'] ?? '',
      approvedAt:
          (data['approvedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      status: data['status'] ?? 'approved',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  ApprovedUserModel copyWith({
    String? userId,
    String? agentId,
    DateTime? approvedAt,
    String? userName,
    String? userEmail,
    String? status,
    DateTime? createdAt,
  }) {
    return ApprovedUserModel(
      userId: userId ?? this.userId,
      agentId: agentId ?? this.agentId,
      approvedAt: approvedAt ?? this.approvedAt,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
