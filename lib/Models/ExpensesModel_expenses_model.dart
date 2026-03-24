// lib/models/expense_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String? id;
  String item;
  String place;
  double amount;
  DateTime date;

  Expense({
    this.id,
    required this.item,
    required this.place,
    required this.amount,
    required this.date,
  });

  // Convert Firestore doc to Expense
  factory Expense.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Expense(
      id: doc.id,
      item: data['item'] ?? '',
      place: data['place'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Convert Expense to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'place': place,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }
}
