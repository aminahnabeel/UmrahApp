import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_umrah_app/Controller/userControllers/expense_track_controller.dart';
import 'package:smart_umrah_app/widgets/ExpenseTrackForm/enpense_track.dart';

class TrackExpenses extends StatelessWidget {
  TrackExpenses({super.key});

  final ExpenseController expenseController = Get.put(ExpenseController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track Expenses",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF101820),
        elevation: 6,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B2A3B), Color(0xFF101820)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (expenseController.expenses.isEmpty) {
                  return const Center(
                    child: Text(
                      "No expenses added yet",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 1;
                    double width = constraints.maxWidth;
                    if (width >= 600 && width < 900) crossAxisCount = 2;
                    if (width >= 900) crossAxisCount = 3;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3,
                      ),
                      itemCount: expenseController.expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenseController.expenses[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF283645),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      expense.item,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      expense.place,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        "dd MMM yyyy",
                                      ).format(expense.date),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${expense.amount.toStringAsFixed(2)} SAR",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.amber,
                                          size: 22,
                                        ),
                                        onPressed: () => showEditExpenseDialog(
                                          context,
                                          expense,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                          size: 22,
                                        ),
                                        onPressed: () => expenseController
                                            .deleteExpense(expense.id!),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => showAddExpenseDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Add Expense",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF15222F),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Expenses:",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${expenseController.totalExpense.value.toStringAsFixed(2)} SAR",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
