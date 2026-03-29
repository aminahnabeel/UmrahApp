// lib/Controller/expense_track_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_umrah_app/Models/ExpensesModel_expenses_model.dart';

class ExpenseController extends GetxController {
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxDouble totalExpense = 0.0.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    if (userId != null) {
      _listenExpenses();
    }
  }

  void _listenExpenses() {
    _firestore
        .collection('user_expenses')
        .doc(userId)
        .collection('entries')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
          expenses.clear();
          double total = 0;
          for (var doc in snapshot.docs) {
            final exp = Expense.fromDocument(doc);
            expenses.add(exp);
            total += exp.amount;
          }
          totalExpense.value = total;
        });
  }

  Future<void> addExpense(Expense expense) async {
    if (userId == null) return;
    await _firestore
        .collection('user_expenses')
        .doc(userId)
        .collection('entries')
        .add(expense.toMap());
  }

  Future<void> editExpense(Expense expense) async {
    if (userId == null || expense.id == null) return;
    await _firestore
        .collection('user_expenses')
        .doc(userId)
        .collection('entries')
        .doc(expense.id)
        .update(expense.toMap());
  }

  Future<void> deleteExpense(String expenseId) async {
    if (userId == null) return;
    await _firestore
        .collection('user_expenses')
        .doc(userId)
        .collection('entries')
        .doc(expenseId)
        .delete();
  }
}
